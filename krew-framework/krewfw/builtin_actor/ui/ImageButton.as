package krewfw.builtin_actor.ui {

    import flash.display.Stage;
    import flash.events.KeyboardEvent;

    import starling.display.Image;

    import krewfw.NativeStageAccessor;
    import krewfw.core.KrewActor;

    /**
     * ありがちなボタン。Image とクリック時のハンドラを指定して使う。
     * 見た目は、押されたときに暗くなって少し下に下がる挙動をとる。
     */
    //------------------------------------------------------------
    public class ImageButton extends KrewActor {

        private var _button:SimpleButton;
        private var _buttonImage:Image;
        private var _clickHandler:Function;
        private var _altKey:int = 0;

        private var _buttonImageColor:uint        = 0xffffff;
        private var _buttonImagePressedColor:uint = 0x888888;

        private var _isAltKeyDown:Boolean = false;

        //------------------------------------------------------------
        /**
         * @param imageName
         * @param clickHandler
         * @param width
         * @param height
         * @param touchWidth
         * @param touchHeight
         * @param buttonX
         * @param buttonY
         * @param altKey 代替キーのキーコード。0 以外を渡すと、そのキーでも押したこととみなされる。
         *               代替キーを指定しない場合は 0 を渡す。定数は flash.ui.Keyboard クラスを参照
         * @param allowMoveMode false なら指が動いていた時に押したとみなさない
         * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Keyboard.html flash.ui.Keyboard
         */
        public function ImageButton(imageName:String, clickHandler:Function,
                                    width:Number, height:Number,
                                    touchWidth:Number, touchHeight:Number,
                                    buttonX:Number, buttonY:Number, altKey:int=0,
                                    allowMoveMode:Boolean=true)
        {
            touchable = true;

            _clickHandler = clickHandler;
            _altKey       = altKey;

            addInitializer(function():void {
                _button = new SimpleButton(
                    _onTouchEndInside, _onTouchEndOutside, _onTouchBegan,
                    touchWidth, touchHeight, allowMoveMode
                );
                _buttonImage = getImage(imageName);
                _buttonImage.touchable = true;
                _button.addImage(_buttonImage, width, height);
                x = buttonX;
                y = buttonY;

                // touch margin
                if (width < touchWidth  ||  height < touchHeight) {
                    _button.addTouchMarginNode(touchWidth, touchHeight);
                }

                addActor(_button);

                _initKeyboardEventListener();
            });
        }

        //------------------------------------------------------------
        // Accessors
        //------------------------------------------------------------

        public function set imageColor(val:uint):void {
            _buttonImageColor  = val;
            _buttonImage.color = _buttonImageColor;
        }

        public function set pressedImageColor(val:uint):void {
            _buttonImagePressedColor = val;
        }

        //------------------------------------------------------------
        // Touch Event
        //------------------------------------------------------------

        protected override function onDispose():void {
            _removeKeyboardEventListener();
        }

        private function _onTouchBegan():void {
            _button.color  = _buttonImagePressedColor;
            _buttonImage.y = 2;
        }

        private function _onTouchEndInside():void {
            if (_clickHandler != null) {
                _clickHandler();
            }
            _enableButton();
        }

        private function _onTouchEndOutside():void {
            _enableButton();
        }

        private function _enableButton():void {
            _button.color  = _buttonImageColor;
            _buttonImage.y = 0;
            _button.touchable = true;
        }

        //------------------------------------------------------------
        // Keyboard Event
        //------------------------------------------------------------

        private function _removeKeyboardEventListener():void {
            if (!_altKey) { return; }

            var stage:Stage = NativeStageAccessor.stage;
            if (stage == null) { return; }

            stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);
        }

        private function _initKeyboardEventListener():void {
            if (!_altKey) { return; }

            var stage:Stage = NativeStageAccessor.stage;
            if (stage == null) { return; }

            stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);
        }

        private function _onKeyDown(event:KeyboardEvent):void {
            if (event.keyCode != _altKey) { return; }
            if (_isAltKeyDown) { return; }

            _isAltKeyDown = true;
            _onTouchEndInside();
        }

        private function _onKeyUp(event:KeyboardEvent):void {
            if (event.keyCode != _altKey) { return; }

            _isAltKeyDown = false;
        }

    }
}
