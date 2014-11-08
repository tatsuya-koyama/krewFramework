package krewdemo.actor.world_test {

    import flash.geom.Rectangle;

    import starling.display.DisplayObject;
    import starling.display.Sprite;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class KrewWorldPrototype extends KrewActor {

        private var _halfScreenWidth:Number;
        private var _halfScreenHeight:Number;
        private var _screenOriginX:Number;
        private var _screenOriginY:Number;

        private var _tree:QuadTreeSprite;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _zoomScale:Number = 1.0;
        private var _viewport:Rectangle;

        //------------------------------------------------------------
        public function KrewWorldPrototype(worldWidth:Number, worldHeight:Number,
                                           screenWidth:Number, screenHeight:Number,
                                           maxQuadTreeDepth:int=6, subNodeMargin:Number=0.2,
                                           screenOriginX:Number=0, screenOriginY:Number=0)
        {
            _halfScreenWidth  = screenWidth  / 2;
            _halfScreenHeight = screenHeight / 2;
            _screenOriginX    = screenOriginX;
            _screenOriginY    = screenOriginY;

            _tree = new QuadTreeSprite(
                worldWidth, worldHeight, 0, 0, 0, maxQuadTreeDepth, subNodeMargin
            );
            super.addChild(_tree);

            _viewport = new Rectangle();
        }

        public override function init():void {}

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

        public function registerActor(actor:KrewActor, width:Number=NaN, height:Number=NaN):void {
            _tree.addActor(actor, width, height);

            if (!actor.hasInitialized) {
                actor.setUp(sharedObj, applyForNewActor, layer, layerName);
            }
        }

        public function registerDisplayObj(child:DisplayObject):void {
            _tree.addDisplayObj(child);
        }

        public override function addActor(actor:KrewActor, putOnDisplayList:Boolean=true):void {
            throw new Error("addActor() is prohibited. You should use registerActor().");
        }

        public override function addChild(child:DisplayObject):DisplayObject {
            throw new Error("addChild() is prohibited. You should use registerDisplayObj().");
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
            _tree.x = -(_focusX * _zoomScale) + _screenOriginX + _halfScreenWidth;
            _tree.y = -(_focusY * _zoomScale) + _screenOriginY + _halfScreenHeight;

            _tree.scaleX = _zoomScale;
            _tree.scaleY = _zoomScale;

            _viewport.setTo(
                _focusX - (_halfScreenWidth  / _zoomScale),
                _focusY - (_halfScreenHeight / _zoomScale),
                _halfScreenWidth  * 2 / _zoomScale,
                _halfScreenHeight * 2 / _zoomScale
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
