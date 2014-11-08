package krewfw.builtin_actor.world {

    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    import starling.display.DisplayObject;
    import starling.display.Sprite;

    import krewfw.core.KrewActor;

    /**
     * 広大な空間を切り取るカメラと、空間内のオブジェクトを管理するもの。
     * オブジェクトはマップの背景など、静的で座標が大きく変動しないものを想定している。
     *
     * KrewWorld には表示倍率の異なる複数のレイヤーを登録できる。
     * 各レイヤーごとに、画面内に見えている範囲のものだけが描画・更新される。
     * （DisplayTree を四分木に吊るすことで、Culling を行っている）
     *
     * Note: 四分木で Culling を行う関係で、レイヤー内では深度を保証できない
     * Note: 現状、レイヤーに置いた Actor を破棄する術が無い
     * Note: Actor の onUpdate は表示領域周辺のものだけが呼ばれるが、
     *       現状イベントハンドラは全てのものが呼ばれる
     * ToDo: 表示領域周辺だけでやる衝突判定
     */
    //------------------------------------------------------------
    public class KrewWorld extends KrewActor {

        private var _layers:Vector.<KrewWorldLayer>;
        private var _layerIndex:Dictionary;

        private var _screenWidth:Number;
        private var _screenHeight:Number;
        private var _screenOriginX:Number;
        private var _screenOriginY:Number;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _zoomScale:Number = 1.0;

        //------------------------------------------------------------
        public function KrewWorld(screenWidth:Number, screenHeight:Number,
                                  screenOriginX:Number=0, screenOriginY:Number=0)
        {
            _screenWidth   = screenWidth;
            _screenHeight  = screenHeight;
            _screenOriginX = screenOriginX;
            _screenOriginY = screenOriginY;

            _layers     = new Vector.<KrewWorldLayer>();
            _layerIndex = new Dictionary();
        }

        //------------------------------------------------------------
        // Actor's event handlers
        //------------------------------------------------------------

        protected override function onDispose():void {
            for each (var layer:KrewWorldLayer in _layers) {
                layer.dispose();
            }
            _layers     = null;
            _layerIndex = null;
        }

        public override function onUpdate(passedTime:Number):void {
            if (QuadTreeSprite.debugMode) {
                _startRecDebugStat();
            }

            for each (var layer:KrewWorldLayer in _layers) {
                layer.setFocusPos(_focusX, _focusY);
                layer.setZoomScale(_zoomScale);
                layer.updateViewport();
                layer.updateWorld(passedTime);
            }
        }

        //------------------------------------------------------------
        // accessors
        //------------------------------------------------------------

        public function getTreeRoot(label:String):QuadTreeSprite {
            var worldLayer:KrewWorldLayer = _getLayerWith(label);
            return worldLayer.treeRoot;
        }

        public function getViewport(label:String):Rectangle {
            var worldLayer:KrewWorldLayer = _getLayerWith(label);
            return worldLayer.viewport;
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        public function addLayer(label:String, layerName:String,
                                 worldWidth:Number, worldHeight:Number,
                                 baseZoomScale:Number=1.0,
                                 maxQuadTreeDepth:int=6, subNodeMargin:Number=0.2):void
        {
            var worldLayer:KrewWorldLayer = new KrewWorldLayer(
                worldWidth, worldHeight, _screenWidth, _screenHeight, baseZoomScale,
                maxQuadTreeDepth, subNodeMargin, _screenOriginX, _screenOriginY, label
            );
            _layers.push(worldLayer);
            _layerIndex[label] = worldLayer;

            createActor(worldLayer, layerName);
        }

        public function putActor(label:String, actor:KrewActor,
                                 width:Number=NaN, height:Number=NaN):void
        {
            var worldLayer:KrewWorldLayer = _getLayerWith(label);
            worldLayer.putActor(actor, width, height);
        }

        public function putDisplayObj(label:String, child:DisplayObject,
                                      width:Number=NaN, height:Number=NaN):void
        {
            var worldLayer:KrewWorldLayer = _getLayerWith(label);
            worldLayer.putDisplayObj(child, width, height);
        }

        public function setFocusPos(x:Number, y:Number):void {
            _focusX = x;
            _focusY = y;
        }

        public function setZoomScale(scale:Number):void {
            _zoomScale = scale;
            if (_zoomScale <= 0) { _zoomScale = 0.001; }
        }

        public function updateScreenSize(screenWidth:Number, screenHeight:Number,
                                         screenOriginX:Number=0, screenOriginY:Number=0):void
        {
            _screenWidth   = screenWidth;
            _screenHeight  = screenHeight;
            _screenOriginX = screenOriginX;
            _screenOriginY = screenOriginY;

            for each (var layer:KrewWorldLayer in _layers) {
                layer.updateScreenSize(screenWidth, screenHeight, screenOriginX, screenOriginY);
            }
        }

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function setDebugEnabled(enabled:Boolean):void {
            QuadTreeSprite.debugMode = enabled;
        }

        private function _startRecDebugStat():void {
            for each (var layer:KrewWorldLayer in _layers) {
                layer.startRecDebugStat();
            }
        }

        public function debug_getNumObjects(label:String):Array {
            return _getLayerWith(label).debug_numObjectByDepth;
        }

        public function debug_getCountDrawActor(label:String):int {
            return _getLayerWith(label).debug_countDrawActorPrev;
        }

        public function debug_getCountDrawDObj(label:String):int {
            return _getLayerWith(label).debug_countDrawDObjPrev;
        }

        public function debug_getCountVisible(label:String):int {
            return _getLayerWith(label).debug_countVisiblePrev;
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _getLayerWith(label:String):KrewWorldLayer {
            if (!_layerIndex[label]) {
                throw new Error("[KrewWorld] Layer not found: " + label);
            }
            return _layerIndex[label];
        }

    }
}
