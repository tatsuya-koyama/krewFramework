package krewdemo.actor.title {

    import feathers.text.BitmapFontTextFormat;

    import starling.display.Image;
    import starling.display.DisplayObject;
    import starling.events.Event;
    import starling.text.TextField;

    import feathers.controls.Button;

    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TextFactory;

    import krewdemo.GameEvent;

    //------------------------------------------------------------
    public class StartButton extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            touchable = true;

            var button:Button = new Button();
            button.label = "Tap to Start";
            button.defaultLabelProperties.textFormat = new BitmapFontTextFormat(
                "tk_courier", 24, 0x1a1816, "center"
            );

            button.paddingTop    = 10;
            button.paddingBottom = 10;
            button.paddingLeft   = 30;
            button.paddingRight  = 30;

            var getBlankImageWithColor:Function = function(color:uint):Image {
                var image:Image = getImage('white');
                image.color = color;
                return image;
            };
            button.defaultSkin = getBlankImageWithColor(0xee9999);
            button.upSkin      = getBlankImageWithColor(0xeeeeee);
            button.hoverSkin   = getBlankImageWithColor(0xeeee99);
            button.downSkin    = getBlankImageWithColor(0x9999ee);

            addChild(button);
            button.validate();
            button.x = -button.width  * 0.5;
            button.y = -button.height * 0.5;
            trace(button.width);
            x = 240;
            y = 220;

            button.addEventListener(Event.TRIGGERED, function(event:Event):void {
                touchable = false;
                sendMessage(GameEvent.EXIT_SCENE);
            });
        }

    }
}
