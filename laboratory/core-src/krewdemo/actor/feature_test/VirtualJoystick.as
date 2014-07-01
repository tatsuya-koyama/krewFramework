package krewdemo.actor.feature_test {

    import flash.geom.Point;

    import starling.display.Image;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class VirtualJoystick extends KrewActor {

        public function VirtualJoystick(stickX:Number=100, stickY:Number=240, size:Number=100) {
            addInitializer(function():void {
                touchable = true;
                var holderImage:Image = getImage('joystick_holder');
                var stickImage :Image = getImage('joystick_ball');

                holderImage.width  = size;
                holderImage.height = size;

                stickImage.width  = size * 0.5;
                stickImage.height = size * 0.5;

                var joystick:SimpleVirtualJoystick = new SimpleVirtualJoystick(
                    holderImage, stickImage, size * 1.3
                );
                addActor(joystick);

                joystick.x = stickX;
                joystick.y = stickY;
                joystick.alpha = 0.7;
            });
        }

    }
}
