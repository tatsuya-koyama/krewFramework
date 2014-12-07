package krewdemo.actor.ui {

    import feathers.text.BitmapFontTextFormat;

    import starling.display.Image;
    import starling.events.Event;

    import feathers.controls.Button;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class TextButton extends KrewActor {

        private var _onPress:Function = null;

        //------------------------------------------------------------
        public function TextButton(buttonX:Number, buttonY:Number, text:String, fontSize:int=16,
                                   paddingH:Number=10, paddingV:Number=5)
        {
            touchable = true;

            addInitializer(function():void {
                var button:Button = new Button();
                button.label = text;
                button.defaultLabelProperties.textFormat = new BitmapFontTextFormat(
                    "tk_courier", fontSize, 0x776044, "center"
                );

                button.paddingTop    = paddingV;
                button.paddingBottom = paddingV;
                button.paddingLeft   = paddingH;
                button.paddingRight  = paddingH;

                button.defaultSkin = _getColorImage(0xee9999);
                button.upSkin      = _getColorImage(0xeeeeee);
                button.hoverSkin   = _getColorImage(0xeeee99);
                button.downSkin    = _getColorImage(0x9999aa);

                addChild(button);
                x = buttonX;
                y = buttonY;

                // centering
                button.validate();
                button.x = -button.width  * 0.5;
                button.y = -button.height * 0.5;

                button.addEventListener(Event.TRIGGERED, function(event:Event):void {
                    _onPress && _onPress(event);
                });
            });
        }

        public function setOnPress(handler:Function):void {
            _onPress = handler;
        }

        private function _getColorImage(color:uint):Image {
            var image:Image = getImage('white');
            image.color = color;
            image.alpha = 0.8;
            return image;
        }

    }
}
