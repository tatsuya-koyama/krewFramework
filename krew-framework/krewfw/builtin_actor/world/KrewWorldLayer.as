package krewfw.builtin_actor.world {

    import flash.geom.Rectangle;

    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.Sprite;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class KrewWorldLayer extends KrewActor {

        private var _halfScreenWidth:Number;
        private var _halfScreenHeight:Number;
        private var _screenOriginX:Number;
        private var _screenOriginY:Number;

        private var _tree:QuadTreeSprite;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _baseZoomScale:Number = 1.0;
        private var _zoomScale:Number     = 1.0;
        private var _viewport:Rectangle;

        //------------------------------------------------------------
        public function KrewWorldLayer(worldWidth:Number, worldHeight:Number,
                                       screenWidth:Number, screenHeight:Number,
                                       baseZoomScale:Number=1.0,
                                       maxQuadTreeDepth:int=6, subNodeMargin:Number=0.2,
                                       screenOriginX:Number=0, screenOriginY:Number=0)
        {
            _halfScreenWidth  = screenWidth  / 2;
            _halfScreenHeight = screenHeight / 2;
            _screenOriginX    = screenOriginX;
            _screenOriginY    = screenOriginY;
            _baseZoomScale    = baseZoomScale;

            _tree = new QuadTreeSprite(
                worldWidth, worldHeight, 0, 0, 0, maxQuadTreeDepth, subNodeMargin
            );
            super.addChild(_tree);

            _viewport = new Rectangle();
        }

        //------------------------------------------------------------
        // Actor's event handlers
        //------------------------------------------------------------

        protected override function onDispose():void {
            _tree.dispose();
            _tree     = null;
            _viewport = null;
        }

        public override function onUpdate(passedTime:Number):void {
            _tree.startRecDebugStat();
            _tree.updateActors(passedTime);
        }

        //------------------------------------------------------------
        // accessors
        //------------------------------------------------------------

        public function get treeRoot():QuadTreeSprite { return _tree; }
        public function get viewport():Rectangle { return _viewport; }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /** width と height はアンカーが中心にあることを想定 */
        public function putActor(actor:KrewActor, width:Number=NaN, height:Number=NaN):void {
            _tree.addActor(actor, width, height);

            if (!actor.hasInitialized) {
                actor.setUp(sharedObj, applyForNewActor, layer, layerName);
            }
        }

        /** width と height はアンカーが中心にあることを想定 */
        public function putDisplayObj(child:DisplayObject, width:Number=NaN, height:Number=NaN,
                                      anchorX:Number=0.5, anchorY:Number=0.5):void
        {
            if (child is Image) {
                var image:Image = child as Image;
                image.pivotX = image.texture.width  * anchorX;
                image.pivotY = image.texture.height * anchorY;
            }

            _tree.addDisplayObj(child, width, height);
        }

        public function setFocusPos(x:Number, y:Number):void {
            _focusX = x;
            _focusY = y;
        }

        public function setZoomScale(scale:Number):void {
            _zoomScale = scale;
            if (_zoomScale <= 0) { _zoomScale = 0.001; }
        }

        public function updateViewport():void {
            var zoomScale:Number = _zoomScale * _baseZoomScale;
            _tree.x = -(_focusX * zoomScale) + _screenOriginX + _halfScreenWidth;
            _tree.y = -(_focusY * zoomScale) + _screenOriginY + _halfScreenHeight;

            _tree.scaleX = zoomScale;
            _tree.scaleY = zoomScale;

            _viewport.setTo(
                _focusX - (_halfScreenWidth  / zoomScale),
                _focusY - (_halfScreenHeight / zoomScale),
                _halfScreenWidth  * 2 / zoomScale,
                _halfScreenHeight * 2 / zoomScale
            );

            _tree.updateVisibility(_viewport);
        }

        public function updateScreenSize(screenWidth:Number, screenHeight:Number,
                                         screenOriginX:Number=0, screenOriginY:Number=0):void
        {
            _halfScreenWidth  = screenWidth  / 2;
            _halfScreenHeight = screenHeight / 2;
            _screenOriginX    = screenOriginX;
            _screenOriginY    = screenOriginY;
        }

    }
}
