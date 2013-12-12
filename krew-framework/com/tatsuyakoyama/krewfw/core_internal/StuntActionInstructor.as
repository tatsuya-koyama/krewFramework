package com.tatsuyakoyama.krewfw.core_internal {
    import com.tatsuyakoyama.krewfw.core.KrewActor;

    public class StuntActionInstructor {

        private var _actor:KrewActor;
        private var _action:StuntAction;
        private var _isAllActionFinished:Boolean = false;

        //------------------------------------------------------------
        public function get actor():KrewActor {
            return _actor;
        }

        public function get action():StuntAction {
            return _action;
        }

        public function get isAllActionFinished():Boolean {
            return _isAllActionFinished;
        }

        //------------------------------------------------------------
        public function StuntActionInstructor(actor:KrewActor, action:StuntAction) {
            _actor  = actor;
            _action = (action) ? action : new StuntAction();
            _action.instructor = this;
        }

        public function update(passedTime:Number):void {
            if (_isAllActionFinished) { return; }

            _action.update(passedTime);
            if (_action.isFinished()) {
                if (!_action.nextAction) {
                    _isAllActionFinished = true;
                    _action = null;
                    return;
                }
                _action = _action.nextAction;
            }
        }
    }
}
