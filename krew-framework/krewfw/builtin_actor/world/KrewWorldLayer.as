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
        private var _label:String;

        private var _tree:QuadTreeSprite;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _baseZoomScale:Number = 1.0;
        private var _zoomScale:Number     = 1.0;
        private var _viewport:Rectangle;

        //----- debug stat
        public var debug_numObjectByDepth:Array;
        public var debug_countDrawActor:int;
        public var debug_countDrawActorPrev:int;
        public var debug_countDrawDObj:int;
        public var debug_countDrawDObjPrev:int;
        public var debug_countVisiblePrev:int;
        public var debug_countVisible:int;

        //------------------------------------------------------------
        public function KrewWorldLayer(worldWidth:Number, worldHeight:Number,
                                       screenWidth:Number, screenHeight:Number,
                                       baseZoomScale:Number=1.0,
                                       maxQuadTreeDepth:int=6, subNodeMargin:Number=0.2,
                                       screenOriginX:Number=0, screenOriginY:Number=0,
                                       label:String="")
        {
            _halfScreenWidth  = screenWidth  / 2;
            _halfScreenHeight = screenHeight / 2;
            _screenOriginX    = screenOriginX;
            _screenOriginY    = screenOriginY;
            _baseZoomScale    = baseZoomScale;
            _label = label;

            _tree = new QuadTreeSprite(
                worldWidth, worldHeight, 0, 0, 0,
                maxQuadTreeDepth, subNodeMargin, label
            );
            super.addChild(_tree);

            _viewport = new Rectangle();
        }

        //------------------------------------------------------------
        // Actor's event handlers
        //------------------------------------------------------------

        public override function init():void {
            listen(QuadTreeSprite.DEBUG_EVENT_ADD, _debug_onObjAdd);
            listen(QuadTreeSprite.DEBUG_EVENT_DRAW_ACTOR, _debug_onActorDraw);
            listen(QuadTreeSprite.DEBUG_EVENT_DRAW_DOBJ, _debug_onDObjDraw);
            listen(QuadTreeSprite.DEBUG_EVENT_ENABLE_NODE, _debug_onNodeEnabled);
        }

        protected override function onDispose():void {
            _tree.dispose();
            _tree     = null;
            _viewport = null;
        }

        public function updateWorld(passedTime:Number):void {
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

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function startRecDebugStat():void {
            debug_countDrawActorPrev = debug_countDrawActor;
            debug_countDrawDObjPrev  = debug_countDrawDObj;
            debug_countVisiblePrev   = debug_countVisible;
            debug_countDrawActor = 0;
            debug_countDrawDObj  = 0;
            debug_countVisible   = 0;
        }

        private function _debug_onObjAdd(args:Object):void {
            if (args.label != _label) { return; }

            if (!debug_numObjectByDepth) {
                debug_numObjectByDepth = [];
                for (var i:int = 0;  i <= _tree.maxDepth;  ++i) {
                    debug_numObjectByDepth[i] = 0;
                }
            }

            debug_numObjectByDepth[args.depth] += 1;
        }

        private function _debug_onActorDraw(args:Object):void {
            if (args.label != _label) { return; }
            debug_countDrawActor += args.num;
        }

        private function _debug_onDObjDraw(args:Object):void {
            if (args.label != _label) { return; }
            debug_countDrawDObj += args.num;
        }

        private function _debug_onNodeEnabled(args:Object):void {
            if (args.label != _label) { return; }
            debug_countVisible += 1;
        }

    }
}
