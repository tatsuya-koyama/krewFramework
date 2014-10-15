package krewfw.utils.as3 {

    import krewfw.utils.krew;

    //------------------------------------------------------------
    public class KrewTimeKeeperTask implements ITimeKeeperTask {

        private var _isInitialFrame:Boolean = true;
        private var _totalPassedTime:Number = 0;
        private var _prevPassedTime:Number  = 0;
        private var _interval:Number;
        private var _task:Function;
        private var _times:int = -1;  // number of runs. -1 means infinity

        //------------------------------------------------------------
        public function KrewTimeKeeperTask(interval:Number, task:Function, times:int=-1) {
            _interval = interval;
            _task     = task;
            _times    = times;

            if (_interval <= 0) {
                krew.fwlog('[Error] interval should not be 0 or less.');
                _interval = 1 / 60;
            }
        }

        public function update(passedTime:Number):void {
            if (_times == 0) { return; }

            // 初期化したフレームでは呼ばれないようにする
            if (_isInitialFrame) {
                _isInitialFrame = false;
                return;
            }

            _totalPassedTime += passedTime;
            while (_totalPassedTime - _prevPassedTime > _interval) {
                _prevPassedTime += _interval;
                _task();
                if (_times > 0) { --_times; }
                if (_times == 0) { return; }
            }
        }

        public function dispose():void {
            _task = null;
        }

        public function isDead():Boolean {
            return (_times == 0);
        }

    }
}
