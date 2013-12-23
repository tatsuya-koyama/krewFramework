package krewdemo.actor.feature_test {

    import flash.geom.Point;

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utility.KrewUtil;

    //------------------------------------------------------------
    public class TileMapTester extends KrewActor {

        private var _tileMapDisplay:QuadBatch;

        // avoid instantiation cost
        private var _point:Point = new Point(0, 0);

        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        //------------------------------------------------------------
        public override function init():void {
            _tileMapDisplay = _makeMapDisplay();
            _tileMapDisplay.scaleX = 1.0;
            _tileMapDisplay.scaleY = 1.0;
            addChild(_tileMapDisplay);

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        private function _makeMapDisplay():QuadBatch {
            var tileMapInfo:Object = getObject('testmap_001');
            var tileLayer:Object   = tileMapInfo.layers[0];
            var tileSet:Object     = tileMapInfo.tilesets[0];

            var quadBatch:QuadBatch = new QuadBatch();

            for (var row:int = 0;  row < 30;  ++row) {
                for (var col:int = 0;  col < 35;  ++col) {

                    var image:Image = _getTileImage(
                        tileMapInfo, tileLayer, tileSet, tileSet.name, col, row
                    );
                    if (!image) { continue; }

                    image.x = col * tileSet.tilewidth;
                    image.y = row * tileSet.tileheight;
                    image.smoothing = TextureSmoothing.NONE;

                    quadBatch.addImage(image);
                }
            }

            return quadBatch;
        }

        /**
         * Tiled Map Editor では空タイルは 0 と表現される。
         * ソースのタイル画像の一番左上は 1 から始まる。
         * 指定したマスが 0 の場合は null を返す。
         *
         * [Note] 以下のタイル画像のフォーマットでテスト：
         *     - Canvas size: 512 x 512
         *     - Tile size: 32 x 32
         *     - spacing: 2
         */
        private function _getTileImage(tileMapInfo:Object, tileLayer:Object, tileSet:Object,
                                       imageName:String, col:uint, row:uint):Image
        {
            // calculate UV coord
            var numMapCol:uint = tileLayer.width;
            var tileIndex:int  = tileLayer.data[(row * numMapCol) + col] - 1;
            if (tileIndex < 0) { return null; }

            // * consider spacing
            var tileWidth :Number = (tileSet.tilewidth  + tileSet.spacing);
            var tileHeight:Number = (tileSet.tileheight + tileSet.spacing);

            var numTileImageCol:uint = tileSet.imagewidth  / tileWidth;
            var numTileImageRow:uint = tileSet.imageheight / tileHeight;
            var tileImageCol:uint = tileIndex % numTileImageCol;
            var tileImageRow:uint = tileIndex / numTileImageCol;

            var uvLeft:Number = (tileWidth  * tileImageCol) / tileSet.imagewidth;
            var uvTop :Number = (tileHeight * tileImageRow) / tileSet.imageheight;
            var uvSize:Number = tileSet.tilewidth / tileSet.imagewidth;

            // make Image with UV
            var image:Image = getImage(imageName);
            image.width  = tileMapInfo.tilewidth;
            image.height = tileMapInfo.tileheight;

            _point.setTo(uvLeft,          uvTop         );  image.setTexCoords(0, _point);
            _point.setTo(uvLeft + uvSize, uvTop         );  image.setTexCoords(1, _point);
            _point.setTo(uvLeft,          uvTop + uvSize);  image.setTexCoords(2, _point);
            _point.setTo(uvLeft + uvSize, uvTop + uvSize);  image.setTexCoords(3, _point);

            var padding:Number = 0.0005;  // そのまま UV 指定するとタイル間にわずかな隙間が見えてしまったので
            _setUv(image, 0, uvLeft         , uvTop         ,  padding,  padding);
            _setUv(image, 1, uvLeft + uvSize, uvTop         , -padding,  padding);
            _setUv(image, 2, uvLeft         , uvTop + uvSize,  padding, -padding);
            _setUv(image, 3, uvLeft + uvSize, uvTop + uvSize, -padding, -padding);

            return image;
        }

        /**
         * vertices index:
         *   0 - 1
         *   | / |
         *   2 - 3
         */
        private function _setUv(image:Image, vertexId:int, x:Number, y:Number,
                                paddingX:Number=0, paddingY:Number=0):void
        {
            _point.setTo(x + paddingX, y + paddingY);
            image.setTexCoords(vertexId, _point);
        }

        private function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX;
            _velocityY = args.velocityY;
        }

        public override function onUpdate(passedTime:Number):void {
            _tileMapDisplay.x += 200 * -_velocityX * passedTime;
            _tileMapDisplay.y += 200 * -_velocityY * passedTime;
        }

    }
}
