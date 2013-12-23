package krewdemo.actor.feature_test {

    import flash.geom.Point;

    import starling.display.Image;

    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utility.KrewUtil;

    //------------------------------------------------------------
    public class VirtualJoystick extends KrewActor {

        public override function init():void {
            touchable = true;
            var holderImage:Image = getImage('joystick_holder');
            var stickImage :Image = getImage('joystick_ball');

            holderImage.width  = 100;
            holderImage.height = 100;

            stickImage.width  = 50;
            stickImage.height = 50;

            var joystick:SimpleVirtualJoystick = new SimpleVirtualJoystick(
                holderImage, stickImage, 130
            );
            addActor(joystick);

            joystick.x = 100;
            joystick.y = 240;
            joystick.alpha = 0.7;
        }

    }
}
