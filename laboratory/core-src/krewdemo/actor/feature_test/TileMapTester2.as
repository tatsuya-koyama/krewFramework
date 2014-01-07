package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.Sprite;
    import starling.display.QuadBatch;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TextFactory;
    import krewfw.starling_utility.TileMapHelper;

    //------------------------------------------------------------
    public class TileMapTester2 extends KrewActor {

        // constants
        private var tileUnitByQB:int = 64;  // maxTileRow / Col の値がこれでぴったり割り切れないとダメ
        private var maxTileRow:int   = 256;
        private var maxTileCol:int   = 256;

        // QuadBatch の配列
        // (tileUnitByQB x tileUnitByQB) のタイルごとに 1 つの QuadBatch にまとめる
        // （1 つの QuadBatch には 8192 個の DisplayObject までしか足せないため）
        private var _tileMapDisplayList:Array = new Array();

        private var _tileMap:Sprite;

        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        private var _addIter:int = 0;
        private var _iterX:int   = 0;
        private var _iterY:int   = 0;
        private var _taskSpeed:Number = 1.0;

        private var _loadingText:TextField;

        //------------------------------------------------------------
        public override function init():void {
            _tileMap = _makeMapRootSprite();
            _tileMap.scaleX = 0.5;
            _tileMap.scaleY = 0.5;
            addChild(_tileMap);

            createActor(_makeLoadingInfoText(), 'l-ui');

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        private function _makeLoadingInfoText():KrewActor {
            var textActor:KrewActor = new KrewActor();
            _loadingText = TextFactory.makeText(
                400, 40, "Loading...", 18, "tk_courier", 0xffffff,
                0, 0, "left", "top", false
            );
            textActor.addText(_loadingText, 70, 10);
            return textActor;
        }

        private function _makeMapRootSprite():Sprite {
            var rootSprite:Sprite = new Sprite();

            var maxQBCol:int = (maxTileCol / tileUnitByQB);
            var maxQBRow:int = (maxTileRow / tileUnitByQB);

            // prepare QuadBatch instances
            for (var row:int = 0;  row < maxQBRow;  ++row) {
                for (var col:int = 0;  col < maxQBCol;  ++col) {

                    var quadBatch:QuadBatch  = new QuadBatch();
                    _tileMapDisplayList.push(quadBatch);
                    rootSprite.addChild(quadBatch);
                }
            }

            return rootSprite;
        }

        /**
         * 逐次的にタイルを画面の DisplayList に足していく
         * （一気にやるとすごく重いので）
         */
        private function _progressAddingTileImage(numAddTask:int=3):void {
            if (_addIter >= (maxTileRow * maxTileCol)) { return; }

            var tileMapInfo:Object = getObject('testmap_001');
            var tileLayer:Object   = tileMapInfo.layers[0];
            var tileSet:Object     = tileMapInfo.tilesets[0];

            var tilesTexture:Texture = getTexture(tileSet.name);
            var maxQBCol:int = (maxTileCol / tileUnitByQB);

            // add task loop
            for (var i:int=0;  i < numAddTask;  ++i) {
                if (_addIter >= (maxTileRow * maxTileCol)) {
                    _onLoadMapComplete();
                    return;
                }

                // select QuadBatch
                var col:int     = _iterX;
                var row:int     = _iterY;
                var qbCol:int   = col / tileUnitByQB;
                var qbRow:int   = row / tileUnitByQB;
                var qbIndex:int = (qbRow * maxQBCol) + qbCol;
                var targetQuadBatch:QuadBatch = _tileMapDisplayList[qbIndex];
                if (!targetQuadBatch) {
                    throw new Error("invalid QuadBatch index: " + qbIndex
                                    + "(" + qbCol + ", " + qbRow + ") ::: " + _addIter);
                }

                _progressIterator();

                // add Image to QuadBatch
                var image:Image = TileMapHelper.getTileImage(
                    tileMapInfo, tileLayer, tileSet, tilesTexture, col, row
                );
                if (!image) { continue; }

                image.x = col * tileSet.tilewidth;
                image.y = row * tileSet.tileheight;
                image.smoothing = TextureSmoothing.NONE;

                targetQuadBatch.addImage(image);
            }

            // display loading ratio
            var loadRatio:Number = _addIter / (maxTileRow * maxTileCol) * 100;
            loadRatio = Math.floor(loadRatio);
            _loadingText.text = "Loading: " + loadRatio + "% (" + _addIter + " tiles)";
        }

        private function _progressIterator():void {
            ++_addIter;

            // 左上からナナメに描いて行くようにイテレータの座標を動かす
            if (_iterX == maxTileCol - 1) {
                _iterX = _iterY + 1;
                _iterY = maxTileRow - 1;
            }
            else if (_iterY == 0) {
                _iterY = _iterX + 1;
                _iterX = 0;
            }
            else if (_iterY >= maxTileRow) {
                _iterX = _iterY - maxTileCol + 1;
                _iterY = maxTileRow - 1;
            }
            else {
                --_iterY;
                ++_iterX;
            }
        }

        private function _onLoadMapComplete():void {
            _loadingText.text = "Load Complete. (" + (maxTileRow * maxTileCol) + " tiles)";
        }

        private function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX;
            _velocityY = args.velocityY;
        }

        public override function onUpdate(passedTime:Number):void {
            _tileMap.x += 800 * -_velocityX * passedTime;
            _tileMap.y += 800 * -_velocityY * passedTime;

            _progressAddingTileImage(Math.floor(_taskSpeed));
            _taskSpeed += 0.1;
            _taskSpeed *= 1.01;
            if (_taskSpeed > 413) { _taskSpeed = 413; }
        }

    }
}
