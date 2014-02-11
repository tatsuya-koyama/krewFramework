package krewfw.builtin_actor.system {

    import krewfw.core.KrewActor;
    import krewfw.utils.krew;

    /**
     * 一つの StateMachine に複数入れて使い回したいような State をつくる。
     * （state 名に自動生成した prefix をつける）
     *
     * 基本的に入りと出しか意識しないような使い方を想定しているが、
     * 外の State から SubState 内の特定の state を指定したい場合は
     * prefix を明示して SubState を new してほしい
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
