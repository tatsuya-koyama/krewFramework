package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TileMapHelper;

    //------------------------------------------------------------
    public class SimpleWalkActor extends KrewActor {

        private var _depth:Number;
        private var _lifeTime:Number = 1.0;

        //------------------------------------------------------------
        public override function init():void {
            _depth = krew.randArea(0.5, 1.0);
            var size:Number = 40 * _depth;
            var image:Image = getImage('rectangle_taro');
            addImage(image, size, size);

            x = krew.randArea(  0, 480);
            y = krew.randArea(-40, 320);
        }

        public override function onUpdate(passedTime:Number):void {
            y += (60 * _depth) * passedTime;

            alpha = 1.0 * _lifeTime;

            _lifeTime -= 2.0 * passedTime;
            if (_lifeTime <= 0) { passAway(); }
        }

    }
}
