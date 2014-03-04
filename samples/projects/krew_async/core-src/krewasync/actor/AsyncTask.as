package krewasync.actor {

    import krewfw.builtin_actor.display.ColorRect;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;

    //------------------------------------------------------------
    public class AsyncTask extends KrewActor {

        private var _initX:Number;
        private var _initY:Number;
        private var _goalX:Number;
        private var _duration:Number;

        private var _failMode:Boolean = false;;

        //------------------------------------------------------------
        public function AsyncTask(initX:Number, initY:Number, goalX:Number,
                                  duration:Number, barColor:uint)
        {
            _initX    = initX;
            _initY    = initY;
            _goalX    = goalX;
            _duration = duration + krew.rand(-0.5, 0.5);
            if (_duration < 0.3) { _duration = 0.3; }

            addInitializer(function():void {
                addImage(getImage("rectangle_taro"), 20, 20);
                x = initX;
                y = initY;

                alpha  = 0;
                scaleX = scaleY = 0;
                act().alphaTo(0.5, 1.0);
                act().scaleTo(0.5, 1.0, 1.0);

                _makeBar(barColor);
            });
        }

        public function get failMode():Boolean { return _failMode; }

        private function _makeBar(barColor:uint):void {
            var width:Number = (_goalX - _initX);
            var rect:ColorRect = new ColorRect(width, 4, false, barColor);
            rect.x = _initX;
            rect.y = _initY - 2;
            rect.blendMode = KrewBlendMode.SCREEN;
            createActor(rect, 'l-back');
        }

        public function kick(onComplete:Function):void {
            var finish:Function = function():void {
                _popUpResult();
                onComplete();
            };

            if (_failMode) {
                var goalX:Number = (_goalX + x) / 2;
                act().moveTo(_duration, goalX, y).justdoit(0, finish);
                act().goon(_duration, function():void {
                    x += krew.rand(-5, 5);
                    y += krew.rand(-5, 5);
                });
                return;
            }

            // ordinary case
            act().moveTo(_duration, _goalX, y).justdoit(0, finish);
        }

        private function _popUpResult():void {
            var popUp:PopUpText = new PopUpText(
                (_failMode) ? "Fail" : "Done",
                (_failMode) ? 0x99ccff : 0xffff99,
                x, y - 8
            );
            createActor(popUp, 'l-ui');
        }

        public function reset():void {
            react();
            x         = _initX;
            y         = _initY;
            alpha     = 1;
            scaleX    = scaleY = 1;
            color     = 0xffffff;
            _failMode = false;
        }

        public function turnOnFailMode():void {
            _failMode = true;
            color = 0xff9999;
        }

    }
}
