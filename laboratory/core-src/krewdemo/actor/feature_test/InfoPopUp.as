package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.builtin_actor.display.ColorRect;
    import krewfw.builtin_actor.ui.SimpleButton;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class InfoPopUp extends KrewActor {

        private var _button:SimpleButton;
        private var _textWindow:KrewActor;
        private var _buttonImage:Image;
        private var _isInfoVisible:Boolean = false;

        //------------------------------------------------------------
        public function InfoPopUp(message:String="Info Text",
                                  imageName:String="info_icon",
                                  fontName:String="tk_courier",
                                  x:Number=25, y:Number=295,
                                  width:Number=30, height:Number=30) {
            touchable = true;

            addInitializer(function():void {
                // text window
                _textWindow = _makeWindow(message, fontName);
                addActor(_textWindow);

                // display toggle button
                _button = new SimpleButton(
                    _onTouchEndInside, _onTouchEndOutside, _onTouchBegan,
                    width + 15, height + 15
                );
                _button.addTouchMarginNode();
                _buttonImage = getImage(imageName);
                _buttonImage.touchable = true;
                _button.addImage(_buttonImage, width, height, 0, 0, 0.5, 0.5);
                _button.x = x;
                _button.y = y;
                addActor(_button);
            });
        }

        private function _onTouchBegan():void {
            _button.color = 0x888888;
            _buttonImage.y = 1;
        }

        private function _onTouchEndInside():void {
            _enableButton();

            _isInfoVisible = !_isInfoVisible
            _textWindow.react();
            if (_isInfoVisible) {
                _textWindow.act().alphaTo(0.2, 0.8);
            } else {
                _textWindow.act().alphaTo(0.2, 0.);
            }
        }

        private function _onTouchEndOutside():void {
            _enableButton();
        }

        private function _enableButton():void {
            _button.color = 0xffffff;
            _buttonImage.y = 0;
            _button.touchable = true;
        }

        private function _makeWindow(str:String, fontName:String):ColorRect {
            var color:uint = 0x000000;
            var rect:ColorRect = new ColorRect(400, 260, false, color, color, color, color);
            rect.x = 40;
            rect.y = 30;
            rect.alpha = 0;

            var text:TextField = _makeText(str, fontName);
            rect.addText(text, 20, 20);

            return rect;
        }

        private function _makeText(str:String, fontName:String):TextField {
            var text:TextField = TextFactory.makeText(
                360, 220, str, 14, fontName, 0xffffff,
                0, 0, "left", "top", false
            );
            return text;
        }

    }
}
