package krewfw.builtin_actor.ui {

    import flash.geom.Point;

    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class SimpleButton extends KrewActor {

        private var _onTouchEndInside:Function;
        private var _onTouchEndOutside:Function;
        private var _onTouchBegan:Function = null;
        private var _touchWidth:Number;
        private var _touchHeight:Number;

        //------------------------------------------------------------
        public function SimpleButton(onTouchEndInside:Function,
                                     onTouchEndOutside:Function=null,
                                     onTouchBegan:Function=null,
                                     touchWidth:Number=0, touchHeight:Number=0) {
            touchable = true;

            _onTouchEndInside  = onTouchEndInside;
            _onTouchEndOutside = onTouchEndOutside;
            _onTouchBegan      = onTouchBegan;
            _touchWidth  = touchWidth;
            _touchHeight = touchHeight;
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }

        /**
         * touchWidth と touchHeight が画像の width, height を
         * 超えるような場合はこれを呼んでおく必要がある
         */
        public override function addTouchMarginNode(touchWidth:Number=0, touchHeight:Number=0):void {
            super.addTouchMarginNode(_touchWidth, _touchHeight);
        }

        private function _onTouch(event:TouchEvent):void {
            var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if (touchBegan) {
                if (_onTouchBegan != null) {
                    _onTouchBegan();
                }
            }

            var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
            if (touchEnded) {
                if (_isInside(touchEnded)) {
                    // ちゃんとボタンの内側で指が離された
                    event.stopPropagation();
                    touchable = false;
                    _onTouchEndInside();
                } else {
                    // ボタンの外で指が離された
                    if (_onTouchEndOutside != null) {
                        _onTouchEndOutside();
                    }
                }
            }
        }

        private function _isInside(touchEnded:Touch):Boolean {
            if (!touchEnded) { return false; }

            var localPos:Point = touchEnded.getLocation(this);
            if (localPos.x < -_touchWidth  / 2) { return false; }
            if (localPos.x >  _touchWidth  / 2) { return false; }
            if (localPos.y < -_touchHeight / 2) { return false; }
            if (localPos.y >  _touchHeight / 2) { return false; }

            return true;
        }
    }
}
