package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.starling.TileMapHelper;

    //------------------------------------------------------------
    public class StarParticle extends KrewActor {

        public static var numCreate:int = 0;
        public static var numExists:int = 0;

        private var _depth:Number;
        private var _vecX:Number;
        private var _vecY:Number;
        private var _lifeTime:Number = 1.0;
        private var _dying:Boolean = false;

        //------------------------------------------------------------
        public function StarParticle(depth:Number, color:uint) {
            ++numCreate;
            _depth = depth;

            addInitializer(function():void {
                var size:Number = 40;
                var image:Image = getImage('star');
                image.blendMode = KrewBlendMode.SCREEN;
                image.color     = color;
                addImage(image, size, size);
            });
        }

        public override function init():void {
            ++numExists;

            scaleX = scaleY = _depth;
            x = 240;
            y = 160;

            var rad:Number = krew.rand(0, 3.14159 * 2);
            _vecX = Math.cos(rad);
            _vecY = Math.sin(rad);
        }

        protected override function onDispose():void {
            --numExists;
        }

        public override function onUpdate(passedTime:Number):void {
            x += (_vecX * 150 * _depth) * passedTime;
            y += (_vecY * 150 * _depth) * passedTime;
            rotation += (3.14 / _depth) * passedTime;

            _depth += passedTime;
            scaleX = scaleY = _depth;

            if (_dying) { return; }

            _lifeTime -= passedTime;
            if (_lifeTime <= 0) {
                _dying = true;
                act().alphaTo(0.2, 0).kill();
            }
        }

    }
}
