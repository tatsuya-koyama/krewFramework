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
    public class StarParticlePooled extends KrewActor {

        public static var numCreate:int = 0;
        public static var numExists:int = 0;
        public static var numPooled:int = 0;

        private var _depth:Number;
        private var _vecX:Number;
        private var _vecY:Number;
        private var _lifeTime:Number;
        private var _dying:Boolean;

        private        var _pooledNext:StarParticlePooled = null;
        private static var _pooledHead:StarParticlePooled = null;

        //------------------------------------------------------------
        public function StarParticlePooled(depth:Number, color:uint) {
            // trace(' +++ construct', id);
            poolable = true;
            reconstruct(depth, color);

            addInitializer(function():void {
                var size:Number = 40;
                var image:Image = getImage('star');
                image.blendMode = KrewBlendMode.SCREEN;
                image.color     = color;
                addImage(image, size, size);
            });
        }

        public function reconstruct(depth:Number, color:uint):void {
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

        public override function init():void {
            // trace(' + init', id);
        }

        protected override function onDispose():void {
            // trace(' - dispose', id);
            --numPooled;
        }

        protected override function onRecycle():void {
            --numExists;
            recycle();
        }

        /**
         * before:
         *    {obj} -> {obj} -> {obj} -> null
         *     head
         *
         * after:
         *
         *    {obj}    {obj} -> {obj} -> null
         *      |       head
         *      V
         *    return
         */
        public static function getObject(depth:Number, color:uint):StarParticlePooled {
            var obj:StarParticlePooled;
            if (_pooledHead == null) {
                ++numCreate;
                obj = new StarParticlePooled(depth, color);
            } else {
                --numPooled;
                obj = _pooledHead;
                _pooledHead = _pooledHead._pooledNext;

                obj._retrieveFromPool();
                obj.reconstruct(depth, color);
                obj._pooledNext = null;
            }
            return obj;
        }

        /**
         * before:
         *    {obj} -> {obj} -> {obj} -> null
         *     head
         *
         * after:
         *      (this)
         *    {new obj} -> {obj} -> {obj} -> {obj} -> null
         *       head
         */
        public function recycle():void {
            // trace(' * recycle:', id); // debug
            ++numPooled;

            if (_pooledHead == null) {
                _pooledHead = this;
                _pooledHead._pooledNext = null;
                // _debugLog(); // debug
                return;
            }

            this._pooledNext = _pooledHead;
            _pooledHead = this;
            // _debugLog(); // debug
        }

        // debug
        private function _debugLog():void {
            var iter:StarParticlePooled = _pooledHead;
            var str:String = "";
            var count:int = 0;
            while (iter != null) {
                str += iter.id + " -> ";
                iter = iter._pooledNext;

                ++count;
                if (count > 9999) { throw new Error();  return; }
            }
            str += "null";
            trace('  *', str);
        }

        public static function disposePool():void {
            var iter:StarParticlePooled = _pooledHead;
            var count:int = 0;
            while (iter != null) {
                // trace(' **************** dispose from pool:', iter.id);
                iter._disposeFromPool();
                var next:StarParticlePooled = iter._pooledNext;
                iter._pooledNext = null;  // delete reference
                iter = next;

                ++count;
                if (count > 9999) { throw new Error();  return; }
            }

            _pooledHead = null;
            numCreate = 0;
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
                //act().alphaTo(0.2, 0).alphaTo(0, 1).alphaTo(0, 0).alphaTo(0, 1).alphaTo(0, 0).kill();
            }
        }

    }
}
