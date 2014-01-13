package krewfw.builtin_actor {

    import krewfw.core.KrewActor;

    /**
     * State Object for KrewStateMachine.
     */
    //------------------------------------------------------------
    public class KrewState extends KrewActor {

        /** KrewStateMachine gives its reference to a state on registration. */
        private var _stateMachine:KrewStateMachine;

        private var _stateId:String;
        private var _nextStateId:String;

        /** Handler called when state starts. */
        private var _onEnterHandler:Function;

        /** Handler called during state or its sub-state is selected. */
        private var _onUpdateHandler:Function;

        /** Handler called when state ends. */
        private var _onExitHandler:Function;

        /** Conditions of transitions by event. */
        private var _guardFunc:Function;

        private var _listenList:Array;
        public  var isListening:Boolean = false;

        private var _parentState:KrewState;
        private var _childStates:Vector.<KrewState>;

        //------------------------------------------------------------
        // accessors
        //------------------------------------------------------------

        public function set stateMachine(fsm:KrewStateMachine):void { _stateMachine = fsm; }

        public function get stateId():String { return _stateId; }

        public function get parentState():KrewState { return _parentState; }
        public function set parentState(state:KrewState):void { _parentState = state; }

        public function get onEnterHandler() :Function { return _onEnterHandler; }
        public function get onUpdateHandler():Function { return _onUpdateHandler; }
        public function get onExitHandler()  :Function { return _onExitHandler; }
        public function get guardFunc()      :Function { return _guardFunc; }

        public function get listenList():Array { return _listenList; }

        public function hasParent():Boolean { return (_parentState != null); }

        //------------------------------------------------------------

        /**
         * Create state with Object key-values.
         *
         * @param stateDef Object including state options such as:
         * <ul>
         *   <li>(Required) id      : {String} - State name.</li>
         *   <li>(Optional) enter   : {Function} - Called when state starts.</li>
         *   <li>(Optional) update  : {Function} - Called during state or sub-state is selected.</li>
         *   <li>(Optional) exit    : {Function} - Called when state ends.</li>
         *   <li>(Optional) guard   : {Function} - Called when event triggered.
         *           Return false to prevent transition.</li>
         *   <li>(Optional) listen  : {Object or Array} - Ex.) [{event: "event_name", to:"target_state_name"}] -
         *           State は自身に遷移した時 event の listen を開始する。それは自身の sub state に
         *           遷移した後も続く。自分の外側の state に移ったとき listen をやめる</li>
         *   <li>(Optional) children: {Array} - Sub state definition list.</li>
         * </ul>
         */
        public function KrewState(stateDef:Object) {
            displayable = false;

            if (!stateDef.id) { throw new Error("[new KrewState] id is required."); }
            _stateId = stateDef.id;

            _onEnterHandler  = stateDef.enter  || null;
            _onUpdateHandler = stateDef.update || null;
            _onExitHandler   = stateDef.exit   || null;
            _guardFunc       = stateDef.guard  || null;

            // listen to event
            if (stateDef.listen != null) {
                if (stateDef.listen is Array) {
                    _listenList = stateDef.listen;
                } else {
                    _listenList = [stateDef.listen];
                }
            }

            // sub states
            if (stateDef.children != null) {
                for each (var subStateDef:* in stateDef.children) {
                    addState(subStateDef);
                }
            }
        }

        protected override function onDispose():void {
            _stateMachine = null;
            _listenList   = null;
            _parentState  = null;
            _childStates  = null;
        }

        /**
         * @see addState
         */
        public static function makeState(stateDef:*):KrewState {
            var state:KrewState;
            if (stateDef is KrewState) {
                return stateDef;
            }
            else if (stateDef is Object) {
                return new KrewState(stateDef);
            }

            throw new Error("[KrewState] Invalid state definition: " + stateDef);
        }

        /**
         * Add sub state.
         *
         * @param stateDef KrewState のインスタンスか、State 定義情報を含む Object.
         *                 Object のフォーマットについては KrewState 及び KrewStateMachine の
         *                 コンストラクタのドキュメントを見よ。
         */
        public function addState(stateDef:*):void {
            var state:KrewState = KrewState.makeState(stateDef);
            state.parentState = this;

            if (!_childStates) {
                _childStates = new Vector.<KrewState>;
            }
            _childStates.push(state);

            krew.log(" $ added [" + _stateId + "] -> " + state.stateId);  // debug
        }

        /**
         * Iterate state tree downward. Passes itself and children to iterator function.
         * @param iterator function(state:KrewState):void
         */
        public function eachChild(iterator:Function):void {
            iterator(this);

            if (_childStates == null) { return; }

            for each (var childState:KrewState in _childStates) {
                childState.eachChild(iterator);
            }
        }

        /**
         * Iterate state tree upward. Passes itself and parents to iterator function.
         * @param iterator function(state:KrewState):void
         */
        public function eachParent(iterator:Function):void {
            iterator(this);

            if (!hasParent()) { return; }

            _parentState.eachParent(iterator);
        }

        //------------------------------------------------------------
        // called by KrewStateMachine
        //------------------------------------------------------------

        /**
         * @private
         * State を開始する。親たちを含めて event の listen を始める.
         *
         * [Note] krewFramework のメッセージングの仕組みで listen を行うのは
         *        KrewStateMachine 側。KrewStateMachine はメッセージを受け取ると
         *        それを現在の State に渡す。State は自分で解決できない場合は
         *        親 State にそれを委譲する
         */
        public function enter():void {
            eachParent(function(state:KrewState):void {
                if (state.listenList == null) { return; }

                for each (var listenInfo:Object in state.listenList) {
                    var event:String       = listenInfo.event;
                    var targetState:String = listenInfo.to;
                    _listenToEvent(state, event, targetState);
                }
            });
        }

        private function _listenToEvent(state:KrewState, event:String, targetState:String):void {
            _stateMachine.listenToStateEvent(event);
            state.isListening = true;

            // state.listen(event, function(args:Object):void {
            //     _onEvent(args, targetState);
            // });
        }

        /**
         * @private
         * State を終了する。親たちを含めて event の listen をやめる
         */
        public function exit():void {
            eachParent(function(state:KrewState):void {
                if (state.listenList == null) { return; }

                for each (var listenInfo:Object in state.listenList) {
                    var event:String = listenInfo.event;
                    _stateMachine.stopListeningToStateEvent(event);
                    state.isListening = false;
                }
            });
        }

        public function onEvent(args:Object, event:String):void {
            if (_isListeningTo(event)) {
                var targetStateId:String = _getTargetStateIdWith(event)
                _stateMachine.changeState(targetStateId);
                return;
            }

            // delegate to parent state
            if (hasParent()) {
                _parentState.onEvent(args, event);
                return;
            }

            krew.log("[KrewState] Warning: Unexpected case in onEvent: " + event);
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _isListeningTo(event:String):Boolean {
            // [Note] listenList が大きくならない想定で、配列を走査して検索
            for each (var listenInfo:Object in listenList) {
                if (listenInfo.event == event) { return true; }
            }
            return false;
        }

        private function _getTargetStateIdWith(event:String):String {
            // [Note] listenList が大きくならない想定で、配列を走査して検索
            for each (var listenInfo:Object in listenList) {
                if (listenInfo.event == event) { return listenInfo.to; }
            }
            return null;
        }

        //------------------------------------------------------------
        // debug method
        //------------------------------------------------------------

        public function dump():void {
            krew.log(krew.str.repeat("v", 50));

            krew.log("_stateId: " + _stateId);
            krew.log("_nextStateId: " + _nextStateId);

            if (isListening) {
                krew.log("isListening: true");
                for each (var listenInfo:Object in listenList) {
                    krew.log("  - " + listenInfo.event);
                }
            } else {
                krew.log("isListening: false");
            }

            krew.log(krew.str.repeat("^", 50));
        }

        public function dumpTree(level:int=0):void {
            var indent:String = krew.str.repeat(" ", level * 4);
            krew.log(indent + _stateId);

            if (!_childStates) { return; }

            for each (var childState:KrewState in _childStates) {
                childState.dumpTree(level + 1);
            }
        }

    }
}
