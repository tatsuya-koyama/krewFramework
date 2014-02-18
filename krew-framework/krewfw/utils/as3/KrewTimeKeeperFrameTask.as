package krewfw.utils.as3 {

    import krewfw.utils.krew;

    /**
     * 経過秒ベースではなくて、n フレーム後に実行したいタスク。
     * 負荷分散のために複数フレームに分けて処理を実行したい場合などに有用
     */
    //------------------------------------------------------------
    public class KrewTimeKeeperFrameTask implements ITimeKeeperTask {

        private var _isInitialFrame:Boolean = true;
        private var _interval:int;
        private var _task:Function;
        private var _times:int = -1;  // number of runs. -1 means infinity
        private var _currentFrame:int;

        //------------------------------------------------------------
        /**
         * 初期化フレームは update を無視する仕様にしているため、interval = 3, times = 2 とした場合、
         * new 後の 4 回目、7 回目の update で task が実行されることになる。
         *
         * 「次のフレームに実行」は interval = 1, times = 1 とすればよい
         */
        public function KrewTimeKeeperFrameTask(interval:int, task:Function, times:int=-1) {
            _interval = interval;
            _task     = task;
            _times    = times;

            if (_interval <= 0) {
                krew.fwlog('[Error] interval frame must be 1 or more.');
                _interval = 1;
            }

            _currentFrame = 0;
        }

        public function update(passedTime:Number):void {
            if (_times == 0) { return; }

            // 初期化したフレームでは呼ばれないようにする
            if (_isInitialFrame) {
                _isInitialFrame = false;
                return;
            }

            ++_currentFrame;
            if (_currentFrame % _interval == 0) {
                _task();
                --_times;
            }
        }

        public function dispose():void {
            _task = null;
        }
    }
}
