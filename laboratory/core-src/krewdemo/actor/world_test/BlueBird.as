package krewdemo.actor.world_test {

    import dragonBones.Armature;

    import starling.display.Sprite;

    import krewfw.core.KrewActor;

    import krewdemo.GameStatic;

    //------------------------------------------------------------
    public class BlueBird extends KrewActor {

        private var _armature:Armature;

        //------------------------------------------------------------
        public override function init():void {
            _armature = GameStatic.boneFactories.makeArmature("bird", "Bird");
            var sprite:Sprite = _armature.display as Sprite;
            sprite.scaleX = sprite.scaleY = 0.2;
            sprite.x = 5;
            sprite.y = 0;
            addChild(sprite);

            _setAnimation("fly");

            x = 240;
            y = 160;
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
            _armature.animation.gotoAndPlay(tag);
        }

    }
}
