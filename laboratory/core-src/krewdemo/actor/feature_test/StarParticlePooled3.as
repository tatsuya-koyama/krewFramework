package krewdemo.actor.feature_test {

    import starling.display.Image;

    import krewfw.core.KrewPoolableActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.as3.KrewObjectPool;

    /**
     * KrewPoolableActor を使ったバージョン
     */
    //------------------------------------------------------------
    public class StarParticlePooled3 extends KrewPoolableActor {

        private static var _objectPool:KrewObjectPool = new KrewObjectPool(StarParticlePooled3);

        public static var numCreate:int = 0;
        public static var numExists:int = 0;
        public static var numPooled:int = 0;

        private var _depth:Number;
        private var _vecX:Number;
        private var _vecY:Number;
        private var _lifeTime:Number;
        private var _dying:Boolean;

        //------------------------------------------------------------
        // KrewPoolable handlers
        //------------------------------------------------------------

        public override function onPoolableInit(params:Object):void {
            ++numCreate;
            var depth:Number = params.depth;
            var color:Number = params.color;

            var size:Number = 40;
            var image:Image = getImage('star');
            image.blendMode = KrewBlendMode.SCREEN;
            image.color     = color;
            addImage(image, size, size);
        }

        public override function onPoolableReinit(params:Object):void {
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

        protected override function onRecycle():void {
            _objectPool.recycle(this);
            --numExists;
            numPooled = _objectPool.numPooled;
        }

        //------------------------------------------------------------
        // For Pooling
        //------------------------------------------------------------

        public static function getObject(depth:Number, color:uint):StarParticlePooled3 {
            var params:Object = {
                depth: depth,
                color: color
            };
            return _objectPool.getObject(params) as StarParticlePooled3;
        }

        public static function disposePool():void {
            _objectPool.dispose();
            numPooled = _objectPool.numPooled;
            numCreate = 0;
        }

        //------------------------------------------------------------
        public function StarParticlePooled3() {
            // trace(' +++ construct', id);
        }

        public override function init():void {
            // trace(' + init', id);
        }

        protected override function onDispose():void {
            // trace(' - dispose', id);
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
