package krewfw.builtin_actor {

    import flash.utils.Dictionary;

    import krewfw.core.KrewActor;

    /**
     * Hierarchical Finite State Machine for krewFramework.
     *1
     * [Note] 後から動的に登録 State を変えるような使い方は想定していない。
     *        また、現状 KrewStateMachine に addState を行った後の state に
     *        sub state を足すような書き方も想定していない。
     */
    //------------------------------------------------------------
    public class KrewStateMachine extends KrewActor {

        // key  : state id
        // value: KrewState instance
        private var _states:Dictionary = new Dictionary();

        private var _currentState:KrewState;

        //------------------------------------------------------------
        public function KrewStateMachine() {

        }

        protected override function onDispose():void {
            _states = null;
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /**
         * @see KrewState.addState
         */
        public function addState(stateDef:*):void {
            var state:KrewState = KrewState.makeState(stateDef);
            _registerStateTree(state);
        }

        public function changeState(stateId:String):void {
            if (!_states[stateId]) {
                throw new Error("[KrewFSM] stateId not registered: " + stateId);
            }

            if (_currentState != null) {
                if (_currentState.onExitHandler != null) {
                    _currentState.onExitHandler();
                }
            }

            var newState:KrewState = _states[stateId];
            if (newState.onEnterHandler != null) {
                newState.onEnterHandler();
            }

            _currentState = newState;
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        /**
         * State を、子を含めて全て Dictionary に保持
         * （State は Composite Pattern で sub state を子に持てる）
         */
        private function _registerStateTree(state:KrewState):void {
            state.each(function(aState:KrewState):void {
                _registerState(aState);
            });
        }

        // State 1 個ぶんを Dictionary に保持
        private function _registerState(state:KrewState):void {
            if (_states[state.stateId]) {
                throw new Error("[KrewFSM] stateId already registered: " + state.stateId);
            }

            _states[state.stateId] = state;

            // ToDo: addActor もしてあげる必要があるかな

            krew.log(" * registered: " + state.stateId);  // debug
        }

        //------------------------------------------------------------
        // debug method
        //------------------------------------------------------------

        public function dumpDictionary():void {
            krew.log(krew.str.repeat("-", 50));
            krew.log(" KrewStateMachine state dictionary dump");
            krew.log(krew.str.repeat("-", 50));

            for each(var state:KrewState in _states) {
                state.dump();
            }
        }

        public function dumpStateTree():void {
            krew.log(krew.str.repeat("-", 50));
            krew.log(" KrewStateMachine state tree dump");
            krew.log(krew.str.repeat("-", 50));

            for each(var state:KrewState in _states) {
                if (!state.hasParent()) {
                    state.dumpTree();
                }
            }
        }

    }
}
