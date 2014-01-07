package krewfw.starling_utility {

    import flash.geom.Point;
    import starling.display.Image;
    import starling.textures.Texture;

    import krewfw.utility.krew;

    /**
     * Tiled Map Editor (http://www.mapeditor.org/) の tmx ファイルから
     * 出力した json をもとに各マスの Image を返すユーティリティ
     */
    //------------------------------------------------------------
    public class TileMapHelper {

        // avoid instantiation cost
        private static var _point:Point = new Point(0, 0);

        /**
         * Tiled Map Editor で出力した json の Object から、
         * 名前でレイヤーのデータを取得する。名前がヒットしなかった場合は null を返す
         */
        public static function getLayerByName(tileMapInfo:Object, layerName:String):Object {
            for each (var layerData:Object in tileMapInfo.layers) {
                if (layerData.name == layerName) {
                    return layerData;
                }
            }
            krew.fwlog("[TileMapHelpr] Layer not found: " + layerName);
            return null;
        }

        /**
         * Tiled Map Editor で出力した json による Object を使って、
         * 指定されたマスに対応するテクスチャを持つ Image を返す。
         * orientation: "orthogonal" 専用。spacing に対応.
         *
         * Tiled Map Editor では空タイルは 0 と表現される。
         * ソースのタイル画像の一番左上は 1 から始まる。
         * 指定したマスが 0 の場合は null を返す.
         *
         * [Note] 以下のタイル画像のフォーマットでテスト：
         * <pre>
         *     - Canvas size: 512 x 512
         *     - Tile size: 32 x 32
         *     - spacing: 2
         * </pre>
         */
        public static function getTileImage(tileMapInfo:Object, tileLayer:Object, tileSet:Object,
                                            tilesTexture:Texture, col:uint, row:uint):Image
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
            var image:Image = new Image(tilesTexture);
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
        private static function _setUv(image:Image, vertexId:int, x:Number, y:Number,
                                       paddingX:Number=0, paddingY:Number=0):void
        {
            _point.setTo(x + paddingX, y + paddingY);
            image.setTexCoords(vertexId, _point);
        }

    }
}
