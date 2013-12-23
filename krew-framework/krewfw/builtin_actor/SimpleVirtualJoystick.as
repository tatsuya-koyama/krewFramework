package krewfw.builtin_actor {

    import flash.geom.Point;

    import starling.display.Image;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import krewfw.core.KrewActor;
    import krewfw.utility.KrewUtil;

    /**
     * いわゆるバーチャルジョイスティック。
     *
     * maxFingerMove に 100 を指定すると、中心から 100 ピクセル指を動かした際に
     * スティックの傾きが最大となる。maxImageMove はこのときのスティック画像の
     * 中心からの移動量である。
     */
    //------------------------------------------------------------
    public class SimpleVirtualJoystick extends KrewActor {

        /**
         * ジョイスティックに対して触れた・動かした・離した際にこのイベントが投げられる。
         * イベントの引数は {velocityX:Number, velocityY:Number}.
         * ジョイスティックの傾きの x, y 成分が [0, 1] の値で渡される。
         * 離した際のイベントでは velocityX, velocityY は共に 0 となる。
         */
        public static const UPDATE_JOYSTICK:String = "krew.updateJoystick";

        public var maxFingerMove:Number = 60;
        public var maxImageMove:Number  = 40;

        private var _stickImage:Image;

        //------------------------------------------------------------
        public function SimpleVirtualJoystick(holderImage:Image, stickImage:Image,
                                              touchSize:Number=100)
        {
            touchable = true;
            addImage(holderImage);
            addImage(stickImage);
            _stickImage = stickImage;

            super.addTouchMarginNode(touchSize, touchSize);
            addEventListener(TouchEvent.TOUCH, _onTouch);
        }

        private function _onTouch(event:TouchEvent):void {
            var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if (touchBegan) { _onTouchStart(touchBegan); }

            var touchMoved:Touch = event.getTouch(this, TouchPhase.MOVED);
            if (touchMoved) { _onTouchMove(touchMoved); }

            var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
            if (touchEnded) { _onTouchEnd(touchEnded); }
        }

        private function _onTouchStart(touchBegan:Touch):void {
            _onTouchMove(touchBegan);
        }

        private function _onTouchMove(touchMoved:Touch):void {
            var localPos:Point = touchMoved.getLocation(this);
            var stickX:Number = localPos.x;
            var stickY:Number = localPos.y;

            var fingerDistance:Number = KrewUtil.getDistance(0, 0, stickX, stickY);
            var scaleToFingerLimit:Number = fingerDistance / maxFingerMove;
            if (scaleToFingerLimit > 1) {
                stickX /= scaleToFingerLimit;
                stickY /= scaleToFingerLimit;
            }

            var moveScale:Number = maxImageMove / maxFingerMove;
            _stickImage.x = stickX * moveScale;
            _stickImage.y = stickY * moveScale;

            sendMessage(UPDATE_JOYSTICK, {
                velocityX: _stickImage.x / maxImageMove,
                velocityY: _stickImage.y / maxImageMove
            });
        }

        private function _onTouchEnd(touchEnded:Touch):void {
            _stickImage.x = 0;
            _stickImage.y = 0;
            sendMessage(UPDATE_JOYSTICK, {velocityX: 0, velocityY: 0});
        }

    }
}
