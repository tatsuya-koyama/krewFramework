package krewfw.core_internal {

    import krewfw.core.KrewActor;

    public class StuntActionInstructor {

        private var _actionCurrent:StuntAction;
        private var _actionHead   :StuntAction;
        private var _isAllActionFinished:Boolean = false;

        //------------------------------------------------------------
        public function get action():StuntAction {
            return _actionCurrent;
        }

        public function get isAllActionFinished():Boolean {
            return _isAllActionFinished;
        }

        //------------------------------------------------------------
        public function StuntActionInstructor(actor:KrewActor, action:StuntAction) {
            _actionCurrent = (action) ? action : new StuntAction();
            _actionCurrent.actor = actor;
            _actionHead = _actionCurrent;
        }

        public function dispose():void {

        }

        public function update(passedTime:Number):void {
            if (_isAllActionFinished) { return; }

            // 先頭の Action はメソッドチェーンのための器でしかないので飛ばす
            if (_actionCurrent == _actionHead  &&  _actionCurrent.nextAction) {
                _actionCurrent = _actionCurrent.nextAction;
            }

            _actionCurrent.update(passedTime);
            if (_actionCurrent.isFinished()) {

                // finish task chain
                if (!_actionCurrent.nextAction) {
                    _isAllActionFinished = true;
                    _actionCurrent = null;
                    _actionHead    = null;
                    return;
                }

                // proceed to next task
                _actionCurrent = _actionCurrent.nextAction;
            }
        }
    }
}
