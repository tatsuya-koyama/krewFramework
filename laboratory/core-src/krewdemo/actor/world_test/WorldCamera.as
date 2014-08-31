package krewdemo.actor.world_test {

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class WorldCamera extends KrewActor {

        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        //------------------------------------------------------------
        public function WorldCamera() {
            displayable = false;
        }

        public override function init():void {
            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        private function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX;
            _velocityY = args.velocityY;
        }

        public override function onUpdate(passedTime:Number):void {
            getLayer(layerName).x += (300 * -_velocityX) * passedTime;
            getLayer(layerName).y += (300 * -_velocityY) * passedTime;
        }

    }
}
