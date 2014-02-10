package krewfw.builtin_actor.system {

    import krewfw.core.KrewActor;
    import krewfw.utils.krew;

    /**
     * 一つの StateMachine に複数入れて使い回したいような State をつくる。
     */
    //------------------------------------------------------------
    public class KrewSubState extends KrewState {

        private static var _globalSubStateId:int = 0;

        public function KrewSubState(stateDef:Object, funcOwner:Object=null, prefix:String=null) {
            if (!prefix) {
                prefix = _generateSubStateId();
            }
            super(stateDef, funcOwner, prefix);
        }

        private static function _generateSubStateId():String {
            ++_globalSubStateId;
            return "SUB:" + _globalSubStateId + "_";
        }

    }
}
