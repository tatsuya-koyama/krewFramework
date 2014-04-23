package krewfw.builtin_actor.system {

    import flash.utils.Dictionary;

    import krewfw.core.KrewActor;

    /**
     * Hierarchical Finite State Machine for krewFramework.
     *
     * [Note] 後から動的に登録 State を変えるような使い方は想定していない。
     *        addState はあるが removeState のインタフェースは用意していない。
     *
     *        また、現状 KrewStateMachine に addState を行った後の state に
     *        sub state を足すような書き方にも対応していない。
     *        KrewStateMachine のコンストラクタで一度に定義してしまうことを推奨する。
     */
    //------------------------------------------------------------
    public class KrewStateMachine extends KrewActor {

        /** If trace log is annoying you, set it false. */
        public static var VERBOSE:Boolean = true;

        // key  : state id
        // value: KrewState instance
        private var _states:Dictionary = new Dictionary();

        // States with constructor argument order. Used for default 'next' settings.
        private var _rootStateList:Vector.<KrewState> = new Vector.<KrewState>();

        private var _currentState:KrewState;

        private var _listenMap:Dictionary = new Dictionary();

        //------------------------------------------------------------
        /**
         * Usage:
         * <pre>
         *     var fsm:KrewStateMachine = new KrewStateMachine([
         *         {
         *             id: "state_1",  // First element will be an initial state.
         *             enter: onEnterFunc,
         *             next: "state_2"  // Default next state is next element of this Array.
         *         },
         *
         *         new YourCustomState(),  // Instead of Object, KrewState instance is OK.
         *
         *         {
         *             id: "state_2",
         *             children: [  // State can contain sub States.
         *                 { id: "state_2_a" },
         *                 { id: "state_2_b" },
         *                 {
         *                     id : "state_2_c",
         *                     listen: {event: "event_1", to: "state_4"},
         *                     guard : guardFunc
         *                 },
         *                 {
         *                     id: "state_2_d",
         *                     listen: [  // Array is also OK.
         *                         {event: "event_2", to: "state_1"},
         *                         {event: "event_3", to: "state_2"}
         *                     ]
         *                 }
         *             ]
         *         },
         *         {
         *             id: "state_3",
         *             listen: {event: "event_1", to: "state_4"}
         *         },
         *         ...
         *     ]);
         * </pre>
         *
         * @param stateDefList Array of KrewState instances or definition objects.
         * @param funcOwner If you speciify functions with name string, pass function-owner object.
         */
        public function KrewStateMachine(stateDefList:Array=null, funcOwner:Object=null) {
            displayable = false;

            _initStates(stateDefList, funcOwner);
        }

        private function _initStates(stateDefList:Array, funcOwner:Object=null):void {
            // guard
            if (stateDefList == null) { return; }

            if (!(stateDefList is Array)) {
                throw new Error("[KrewFSM] Constructor argument must be Array.");
            }
            if (stateDefList.length == 0) { return; }

            // do init
            addInitializer(function():void {
                for each (var stateDef:* in stateDefList) {
                    addState(stateDef, funcOwner);
                }

                _setDefaultNextStates(_rootStateList);
                _setInitialState(stateDefList);
            });
        }

        private function _setInitialState(stateDefList:Array):void {
            var firstDef:* = stateDefList[0];
            var initStateId:String;

            if (firstDef is KrewState) {
                initStateId = firstDef.stateId;
            }
            else if (firstDef is Object) {
                initStateId = firstDef.id;
            }
            else {
                throw new Error("[KrewFSM] Invalid first stateDef.");
            }

            changeState(initStateId);
        }

        /**
         * next が指定されていない state について、コンストラクタで渡した定義で
         * 上から下になぞるように next を設定していく。
         * この関数は再帰で、ツリーの末端の子 state を返す
         */
        private function _setDefaultNextStates(stateList:Vector.<KrewState>):KrewState {
            if (stateList.length == 0) { return null; }

            for (var i:int = 0;  i < stateList.length;  ++i) {
                var state:KrewState = stateList[i];

                if (state.nextStateId == null) {
                    if (state.hasChildren()) {
                        state.nextStateId = state.childStates[0].stateId;
                    }
                    else if (i + 1 <= stateList.length - 1) {
                        state.nextStateId = stateList[i + 1].stateId;
                    }
                }

                if (state.hasChildren()) {
                    var edgeState:KrewState = _setDefaultNextStates(state.childStates);

                    if (edgeState.nextStateId == null) {
                        if (i + 1 <= stateList.length - 1) {
                            edgeState.nextStateId = stateList[i + 1].stateId;
                        } else {
                            return edgeState;
                        }
                    }
                }
            }

            var edgeState:KrewState = krew.last(stateList);
            if (!edgeState.hasParent()) { return null; }

            return edgeState;
        }

        protected override function onDispose():void {
            for each (var state:KrewState in _states) {
                state.eachChild(function(childState:KrewState):void {
                    childState.dispose();
                });
            }

            _states        = null;
            _rootStateList = null;
            _currentState  = null;
            _listenMap     = null;
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /**
         * @see KrewState.addState
         */
        public function addState(stateDef:*, funcOwner:Object=null):void {
            var state:KrewState = KrewState.makeState(stateDef, funcOwner);
            _registerStateTree(state);
            _rootStateList.push(state);
        }

        public function changeState(stateId:String):void {
            if (!_states[stateId]) {
                throw new Error("[KrewFSM] stateId not registered: " + stateId);
            }

            var oldStateId:String = "null";
            var oldState:KrewState = _currentState;
            var newState:KrewState = _states[stateId];

            // Good bye old state
            if (_currentState != null) {
                oldStateId = _currentState.stateId;
                oldState.exit();
                oldState.end(newState);
            }

            _log("[Info] [KrewFSM] SWITCHED: " + newState.stateId + "  <-  " + oldStateId);

            // Hello new state
            _currentState = newState;
            newState.begin(oldState);
            newState.enter();
        }

        /**
         * If given state is current state OR parent of current state, return true.
         * For example, when current state is "A-sub", and it is child state of "A",
         * both isState("A-sub") and isState("A") returns true.
         *
         * 現在の state が指定したものか、指定したものの子 state なら true を返す。
         * 例えば現在の state "A-sub" が "A" の子 state であるとき、isState("A-sub") でも
         * isState("A") でも true が返る。
         */
        public function isState(stateName:String):Boolean {
            if (_currentState.stateId == stateName) { return true; }

            var stateIter:KrewState = _currentState;
            while (stateIter.hasParent()) {
                stateIter = stateIter.parentState;
                if (stateIter.stateId == stateName) { return true; }
            }
            return false;
        }

        public function getState(stateId:String):KrewState {
            if (!_states[stateId]) {
                throw new Error("[KrewFSM] stateId not registered: " + stateId);
            }
            return _states[stateId];
        }

        public function get currentState():KrewState {
            return _currentState;
        }

        //------------------------------------------------------------
        // called by KrewState
        //------------------------------------------------------------

        public function listenToStateEvent(event:String):void {
            if (_listenMap[event]) { return; }  // already listening by other state

            listen(event, function(args:Object):void {
                _onEvent(args, event);
            })

            _listenMap[event] = true;
        }

        public function stopListeningToStateEvent(event:String):void {
            if (!_listenMap[event]) { return; }  // already stopped by other state

            stopListening(event);

            _listenMap[event] = false;
        }

        //------------------------------------------------------------
        // called by krewFramework
        //------------------------------------------------------------

        public override function onUpdate(passedTime:Number):void {
            if (_currentState == null) { return; }

            _currentState.eachParent(function(state:KrewState):void {
                if (state.onUpdateHandler == null) { return; }
                state.onUpdateHandler(state, passedTime);
            });
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _onEvent(args:Object, event:String):void {
            _log("[Info] [KrewFSM] EVENT: " + event);
            _currentState.onEvent(args, event);
        }

        /**
         * State を、子を含めて全て Dictionary に保持
         * （State は Composite Pattern で sub state を子に持てる）
         */
        private function _registerStateTree(state:KrewState):void {
            state.eachChild(function(aState:KrewState):void {
                _registerState(aState);
            });
        }

        // State 1 個ぶんを Dictionary に保持
        private function _registerState(state:KrewState):void {
            if (_states[state.stateId]) {
                throw new Error("[KrewFSM] stateId already registered: " + state.stateId);
            }

            _states[state.stateId] = state;
            state.stateMachine = this;
        }

        //------------------------------------------------------------
        // debug method
        //------------------------------------------------------------

        private function _log(text:String):void {
            if (!VERBOSE) { return; }
            krew.fwlog(text);
        }

        public function dumpDictionary():void {
            krew.log(krew.str.repeat("-", 50));
            krew.log(" KrewStateMachine state dictionary dump");
            krew.log(krew.str.repeat("-", 50));

            for each(var state:KrewState in _states) {
                krew.log(" - " + state.stateId);
            }
            krew.log(krew.str.repeat("^", 50));
        }

        public function dumpDictionaryVerbose():void {
            krew.log(krew.str.repeat("-", 50));
            krew.log(" KrewStateMachine state dictionary dump -v");
            krew.log(krew.str.repeat("-", 50));

            for each(var state:KrewState in _states) {
                state.dump();
            }
        }

        public function dumpState(stateId:String):void {
            _states[stateId].dump();
        }

        public function dumpStateTree():void {
            krew.log(krew.str.repeat("-", 50));
            krew.log(" KrewStateMachine state tree dump");
            krew.log(krew.str.repeat("-", 50));

            for each(var state:KrewState in _rootStateList) {
                state.dumpTree();
            }
            krew.log(krew.str.repeat("^", 50));
        }

    }
}
