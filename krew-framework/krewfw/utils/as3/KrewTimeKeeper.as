package krewfw.utils.as3 {

    import krewfw.KrewConfig;

    //------------------------------------------------------------
    public class KrewTimeKeeper {

        private var _tasks:Vector.<ITimeKeeperTask> = new Vector.<ITimeKeeperTask>();

        //------------------------------------------------------------
        public function addPeriodicTask(interval:Number, task:Function, times:int=-1):void {
            _tasks.push(
                new KrewTimeKeeperTask(interval, task, times)
            );
        }

        public function addPeriodicFrameTask(interval:int, task:Function, times:int=-1):void {
            _tasks.push(
                new KrewTimeKeeperFrameTask(interval, task, times)
            );
        }

        /**
         * [ToDo]: 終わった task は削除した方がいいんじゃないの
         */
        public function update(passedTime:Number):void {
            for each (var task:ITimeKeeperTask in _tasks) {
                task.update(passedTime);
            }
        }

        public function dispose():void {
            for each (var task:ITimeKeeperTask in _tasks) {
                task.dispose();
            }
            _tasks = null;
        }

        /**
         * 基本的には経過時間なんだけど、それだとフレームレートスパイクしたときに
         * キャラがワープするみたいな悲惨なことになるので、一定以上は
         * 単純な処理落ちにするような、ゲーム的に妥当な経過時間 [秒] を返す
         */
        public static function getReasonablePassedTime(passedTime:Number):Number {
            var originalPassedTime:Number = passedTime;
            var acceptableTime:Number = 1.0 / KrewConfig.ALLOW_DELAY_FPS;
            if (originalPassedTime > acceptableTime) {
                return acceptableTime;
            }

            // なんだか知らないが、Android でプレイし続けているとごくまれに
            // 経過時間がマイナスになったかのような謎の挙動をすることがあるんだ…
            if (originalPassedTime < 0) { return 0; }

            return originalPassedTime;
        }
    }
}
