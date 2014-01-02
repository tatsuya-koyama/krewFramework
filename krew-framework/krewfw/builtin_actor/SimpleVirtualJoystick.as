package krewfw.builtin_actor {

    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Quad;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import krewfw.NativeStageAccessor;
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

        private var _stickImage:DisplayObject;

        private var _keyDowns:Dictionary = new Dictionary();
        private var _numKeyDown:int = 0;

        //------------------------------------------------------------
        public function SimpleVirtualJoystick(holderImage:Image=null,
                                              stickImage:Image=null,
                                              touchSize:Number=130)
        {
            touchable = true;

            // default display object
            if (holderImage == null) {
                var defaultHolder:Quad = new Quad(100, 100, 0x777777);
                var defaultStick :Quad = new Quad( 50,  50, 0xee4444);
                _setCenterPivot(defaultHolder);
                _setCenterPivot(defaultStick);
                addChild(defaultHolder);
                addChild(defaultStick);
            } else {
                addImage(holderImage);
                addImage(stickImage);
            }

            _stickImage = stickImage;

            super.addTouchMarginNode(touchSize, touchSize);
            addEventListener(TouchEvent.TOUCH, _onTouch);

            _initKeyboardEventListener();
        }

        private function _setCenterPivot(dispObj:DisplayObject):void {
            dispObj.pivotX = dispObj.width  / 2;
            dispObj.pivotY = dispObj.height / 2;
        }

        protected override function onDispose():void {
            var stage:Stage = NativeStageAccessor.stage;
            if (stage == null) { return; }

            stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);
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

        public override function onUpdate(passedTime:Number):void {
            _onKeyUpdate();
        }

        //------------------------------------------------------------
        // Keyboard Event
        //------------------------------------------------------------
        public static const LEFT :uint = 37;
        public static const UP   :uint = 38;
        public static const RIGHT:uint = 39;
        public static const DOWN :uint = 40;

        private function _initKeyboardEventListener():void {
            var stage:Stage = NativeStageAccessor.stage;
            if (stage == null) { return; }

            stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);
        }

        private function _onKeyDown(event:KeyboardEvent):void {
            if (!_keyDowns[event.keyCode]) { ++_numKeyDown; }
            _keyDowns[event.keyCode] = true;
        }

        private function _onKeyUp(event:KeyboardEvent):void {
            if (_keyDowns[event.keyCode]) { --_numKeyDown; }
            _keyDowns[event.keyCode] = false;

            // 全部離したタイミング
            if (_numKeyDown == 0) {
                sendMessage(UPDATE_JOYSTICK, {
                    velocityX: 0,
                    velocityY: 0
                });
            }
        }

        /**
         * PC 用にキーボードでの操作でもメッセージを投げる。
         * マウスでジョイスティックが動かされていた場合はそちらを優先
         */
        private function _onKeyUpdate():void {
            if (_numKeyDown == 0) { return; }
            if (!(_stickImage.x == 0  &&  _stickImage.y == 0)) { return; }

            var keyVelocityX:Number = 0;
            var keyVelocityY:Number = 0;
            if (_keyDowns[SimpleVirtualJoystick.LEFT ]) { keyVelocityX -= 1.0; }
            if (_keyDowns[SimpleVirtualJoystick.RIGHT]) { keyVelocityX += 1.0; }
            if (_keyDowns[SimpleVirtualJoystick.UP   ]) { keyVelocityY -= 1.0; }
            if (_keyDowns[SimpleVirtualJoystick.DOWN ]) { keyVelocityY += 1.0; }

            sendMessage(UPDATE_JOYSTICK, {
                velocityX: keyVelocityX,
                velocityY: keyVelocityY
            });
        }

    }
}
