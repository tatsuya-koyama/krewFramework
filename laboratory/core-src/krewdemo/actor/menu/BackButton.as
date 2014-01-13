package krewdemo.actor.menu {

    import starling.display.Image;

    import krewfw.core.KrewActor;
    import krewfw.builtin_actor.ui.SimpleButton;

    import krewdemo.GameEvent;

    /**
     * Dispatch GameEvent.BACK_SCENE event when it clicked.
     */
    //------------------------------------------------------------
    public class BackButton extends KrewActor {

        private var _button:SimpleButton;
        private var _buttonImage:Image;

        //------------------------------------------------------------
        public function BackButton(x:Number=450, y:Number=290,
                                   width:Number=50, height:Number=50) {
            touchable = true;

            addInitializer(function():void {
                _button = new SimpleButton(
                    _onTouchEndInside, _onTouchEndOutside, _onTouchBegan, width, height
                );
                _buttonImage = getImage('back_button');
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
            sendMessage(GameEvent.BACK_SCENE);
            _enableButton();
        }

        private function _onTouchEndOutside():void {
            _enableButton();
        }

        private function _enableButton():void {
            _button.color = 0xffffff;
            _buttonImage.y = 0;
            _button.touchable = true;
        }

    }
}
