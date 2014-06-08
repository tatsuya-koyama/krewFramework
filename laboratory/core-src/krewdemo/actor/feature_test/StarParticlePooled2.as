package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.as3.KrewObjectPool;
    import krewfw.utils.as3.KrewPoolable;
    import krewfw.utils.starling.TileMapHelper;

    /**
     * ライブラリ化した KrewObjectPool を使ったバージョン
     */
    //------------------------------------------------------------
    public class StarParticlePooled2 extends KrewActor implements KrewPoolable {

        public static var _objectPool:KrewObjectPool = new KrewObjectPool(StarParticlePooled2);

        public static var numCreate:int = 0;
        public static var numExists:int = 0;
        public static var numPooled:int = 0;

        private var _depth:Number;
        private var _vecX:Number;
        private var _vecY:Number;
        private var _lifeTime:Number;
        private var _dying:Boolean;

        //------------------------------------------------------------
        // implementation of KrewPoolable
        //------------------------------------------------------------

        public function onPooledObjectCreate(params:Object):void {
            ++numCreate;
            var depth:Number = params.depth;
            var color:Number = params.color;

            addInitializer(function():void {
                var size:Number = 40;
                var image:Image = getImage('star');
                image.blendMode = KrewBlendMode.SCREEN;
                image.color     = color;
                addImage(image, size, size);
            });
        }

        public function onPooledObjectInit(params:Object):void {
            var depth:Number = params.depth;
            var color:Number = params.color;

            ++numExists;
            _depth = depth;

            _lifeTime = krew.rand(0.8, 1.2);
            _dying    = false;
            alpha     = 1;

            scaleX = scaleY = _depth;
            x = 240;
            y = 160;

            var rad:Number = krew.rand(0, 3.14159 * 2);
            _vecX = Math.cos(rad);
            _vecY = Math.sin(rad);
        }

        public function onRetrieveFromPool(params:Object):void {
            --numPooled;
            _retrieveFromPool();
        }

        public function onPooledObjectRecycle():void {
            ++numPooled;
        }

        public function onDisposeFromPool():void {
            --numPooled;
            _disposeFromPool();
        }

        //------------------------------------------------------------
        public function StarParticlePooled2() {
            // trace(' +++ construct', id);
            poolable = true;
        }

        public override function init():void {
            // trace(' + init', id);
        }

        protected override function onDispose():void {
            // trace(' - dispose', id);
        }

        protected override function onRecycle():void {
            --numExists;
            _objectPool.recycle(this);
        }

        public static function getObject(depth:Number, color:uint):StarParticlePooled2 {
            var params:Object = {
                depth: depth,
                color: color
            };
            return _objectPool.getObject(params) as StarParticlePooled2;
        }

        public static function disposePool():void {
            _objectPool.dispose();
            numCreate = 0;
        }

        //------------------------------------------------------------
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
                //act().alphaTo(0.2, 0).alphaTo(0, 1).alphaTo(0, 0).alphaTo(0, 1).alphaTo(0, 0).kill();
            }
        }

    }
}
