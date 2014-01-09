package krewfw.builtin_actor {

    import krewfw.core.KrewActor;

    /**
     * State Object for KrewStateMachine.
     */
    //------------------------------------------------------------
    public class KrewState extends KrewActor {

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

        private var _parentState:KrewState;
        private var _childStates:Vector.<KrewState>;

        //------------------------------------------------------------
        public function get stateId():String { return _stateId; }

        public function get parentState():KrewState { return _parentState; }
        public function set parentState(state:KrewState):void { _parentState = state; }

        public function get onEnterHandler() :Function { return _onEnterHandler; }
        public function get onUpdateHandler():Function { return _onUpdateHandler; }
        public function get onExitHandler()  :Function { return _onExitHandler; }
        public function get guardFunc()      :Function { return _guardFunc; }

        public function hasParent():Boolean { return (_parentState != null); }

        //------------------------------------------------------------

        /**
         * Create state with Object key-values.
         *
         * @param stateDef Object including state options such as:
         * <ul>
         *   <li>(Required) id: {String} - State name.</li>
         *   <li>(Optional) enter: {Function} - Called when state starts.</li>
         *   <li>(Optional) update: {Function} - Called during state or sub-state is selected.</li>
         *   <li>(Optional) exit: {Function} - Called when state ends.</li>
         *   <li>(Optional) guard: {Function} - Called when event triggered.
         *           Return false to prevent transition.</li>
         * </ul>
         */
        public function KrewState(stateDef:Object) {
            if (!stateDef.id) { throw new Error("[new KrewState] id is required."); }
            _stateId = stateDef.id;

            _onEnterHandler  = stateDef.enter  || null;
            _onUpdateHandler = stateDef.update || null;
            _onExitHandler   = stateDef.exit   || null;
            _guardFunc       = stateDef.guard  || null;
        }

        protected override function onDispose():void {
            _parentState = null;
            _childStates = null;
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
                return KrewState.fromObj(stateDef);
            }

            throw new Error("[KrewState] Invalid state definition: " + stateDef);
        }

        /**
           ToDo: これは消す
         * You should not use this constructor directly.
         * Factory method fromObj() is recommended.
         */
        public static function fromObj(stateDef:Object):KrewState {
            return new KrewState("todo");
        }

        /**
         * Add sub state.
         *
         * @param stateDef KrewState のインスタンスか、State 定義情報を含む Object.
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
         * Iterate state tree. Passes itself and children to iterator function.
         * @param iterator function(state:KrewState):void
         */
        public function each(iterator:Function):void {
            iterator(this);

            if (!_childStates) { return; }

            for each (var childState:KrewState in _childStates) {
                childState.each(iterator);
            }
        }

        //------------------------------------------------------------
        // debug method
        //------------------------------------------------------------

        public function dump():void {
            krew.log("_stateId: " + _stateId);
            krew.log("_nextStateId: " + _nextStateId);
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
