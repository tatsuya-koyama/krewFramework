package krewasync.actor {

    import krewfw.builtin_actor.display.ColorRect;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.as3.KrewAsync;

    import krewasync.GameEvent;

    //------------------------------------------------------------
    public class AsyncTaskRunner extends KrewActor {

        private var _tasks:Array = [];

        private const TASK_DATA:Array = [
            // x, goalX, y, duration, barColor
             [ 40,  80, 160, 0.8, 0x552222]  // 0
            ,[ 90, 130, 160, 0.8, 0x552222]  // 1
            ,[140, 180, 160, 0.8, 0x552222]  // 2

            ,[190, 250, 110, 0.8, 0x223355]  // 3
            ,[190, 250, 160, 1.8, 0x223355]  // 4
            ,[190, 250, 210, 1.4, 0x223355]  // 5

            ,[260, 290, 160, 0.8, 0x552222]  // 6

            ,[300, 330, 120, 0.8, 0x335522]  // 7
            ,[300, 350, 200, 1.4, 0x335522]  // 8
            ,[340, 390,  90, 0.4, 0x223355]  // 9
            ,[340, 390, 150, 1.0, 0x223355]  // 10
            ,[360, 390, 200, 2.0, 0x335522]  // 11

            ,[410, 440, 140, 0.8, 0x552222]  // 12
        ];

        /**
         * Sequence:
         *                                     |9  ->..|   |
         *               |3 ->....|       |7 > |       |...|
         *               |        |       |    |10 --->|   | > 12
         *   0 > 1 > 2 > |4 ----->| > 6 > |                |
         *               |        |       |8 ----- 11 ---->|
         *               |5 --->..|
         *
         */
        //------------------------------------------------------------
        public override function init():void {
            _makeTasks();
            _makePipes();

            listen(GameEvent.KICK_RUNNER, _onKickRunner);
            listen(GameEvent.KICK_RUNNER_WITH_FAIL, _onKickRunnerWithFail);
        }

        private function _makeTasks():void {
            for each (var data:Array in TASK_DATA) {
                var x       :Number = data[0];
                var goalX   :Number = data[1];
                var y       :Number = data[2];
                var duration:Number = data[3];
                var barColor:uint   = data[4];

                var task:AsyncTask = new AsyncTask(x, y, goalX, duration, barColor);
                createActor(task);
                _tasks.push(task);
            }
        }

        private function _onKickRunner(args:Object):void {
            trace('done');
            _resetTasks();
            _goAsyncSequence();
        }

        private function _onKickRunnerWithFail(args:Object):void {
            trace('fail');
            _resetTasks();

            var randomTask:AsyncTask = krew.list.sample(_tasks);
            randomTask.turnOnFailMode();

            _goAsyncSequence();
        }

        /**
         * Main feature of this sample!
         */
        private function _goAsyncSequence():void {
            krew.async({
                serial: [
                    _getKickFunc(0),
                    _getKickFunc(1),
                    _getKickFunc(2),

                    {parallel: [
                        _getKickFunc(3),
                        _getKickFunc(4),
                        _getKickFunc(5)
                    ]},

                    _getKickFunc(6),

                    {parallel: [

                        {serial: [
                            _getKickFunc(7),

                            {parallel: [
                                _getKickFunc(9),
                                _getKickFunc(10)
                            ]}
                        ]},

                        {serial: [
                            _getKickFunc(8),
                            _getKickFunc(11)
                        ]}
                    ]},

                    _getKickFunc(12)
                ],
                error: _onCatchError,
                anyway: function():void {
                    sendMessage(GameEvent.END_ALL_TASK);
                }
            });
        }

        private function _getKickFunc(taskIndex:int):Function {
            return function(async:KrewAsync):void {
                var task:AsyncTask = _tasks[taskIndex];
                var onComplete:Function = (task.failMode) ? async.fail : async.done;
                task.kick(onComplete);
            };
        }

        private function _onCatchError():void {
            var popUp:PopUpText = new PopUpText(
                "Error Handling Done.", 0xff9999, 240, 250, 1.0
            );
            createActor(popUp, 'l-ui');
        }

        private function _resetTasks():void {
            for each (var task:AsyncTask in _tasks) {
                task.reset();
            }
        }

        private function _makePipes():void {
            _makePipe(190, 110, 210);
            _makePipe(250, 110, 210);
            _makePipe(300, 120, 200);
            _makePipe(340,  90, 150);
            _makePipe(390,  90, 200);
        }

        private function _makePipe(x:Number, y:Number, y_to:Number, barColor:uint=0x444444):void {
            var height:Number = (y_to - y);
            var rect:ColorRect = new ColorRect(4, height, false, barColor);
            rect.x = x;
            rect.y = y;
            rect.blendMode = KrewBlendMode.SCREEN;
            createActor(rect, 'l-back');
        }

    }
}
