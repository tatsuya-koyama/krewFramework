package krewdemo.actor.world_test {

    import dragonBones.Armature;

    import starling.display.Sprite;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;

    import krewdemo.GameStatic;

    //------------------------------------------------------------
    public class BlueBird extends KrewActor {

        private var _armature:Armature;
        private var _sprite:Sprite;
        private var _currentTag:String;

        //------------------------------------------------------------
        public override function init():void {
            _armature = GameStatic.boneFactories.makeArmature("bird", "Bird");
            _sprite   = _armature.display as Sprite;
            _sprite.scaleX = _sprite.scaleY = 0.2;
            _sprite.x = 12;
            _sprite.y = 0;
            addChild(_sprite);

            _setAnimation("fly");

            x = 240;
            y = 160;

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        protected override function onDispose():void {
            if (_armature) {
                _armature.dispose();
                _armature = null;
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _armature.advanceTime(passedTime);
        }

        private function _setAnimation(tag:String):void {
            if (tag == _currentTag) { return; }

            _armature.animation.gotoAndPlay(tag);
            _currentTag = tag;
        }

        /** update motion with key direction */
        private function _onUpdateJoystick(args:Object):void {
            if (args.velocityX > 0) {
                scaleX = 1.0;
                _sprite.x = 4;
            }
            if (args.velocityX < 0) {
                scaleX = -1.0;
                _sprite.x = -8;
            }

            if (Math.abs(args.velocityX) > 0.5  &&  args.velocityY > -0.5) {
                _setAnimation("glide");
            }
            else if (args.velocityY > 0.5) {
                _setAnimation("glide");
            }
            else {
                _setAnimation("fly");
            }
        }

    }
}
