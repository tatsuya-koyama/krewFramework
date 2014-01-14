package krewfw.utils.starling {

    import flash.geom.Point;
    import starling.display.Image;
    import starling.textures.Texture;

    import krewfw.utils.krew;

    /**
     * Tiled Map Editor (http://www.mapeditor.org/) の tmx ファイルから
     * 出力した json をもとに各マスの Image を返すユーティリティ.
     *
     * [Note] 現状、1 つの layer に 1 つの tileSet だけを使用していることを想定。
     *        Draw Call などをケアすると必然的にそういった使い方になるだろうしね
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
            krew.fwlog("[Error] [TileMapHelper] Layer not found: " + layerName);
            return null;
        }

        /**
         * Tiled Map Editor で出力した json の Object から、
         * 名前でタイルセットのデータを取得する。名前がヒットしなかった場合は null を返す
         */
        public static function getTileSetByName(tileMapInfo:Object, tileSetName:String):Object {
            for each (var tileSet:Object in tileMapInfo.tilesets) {
                if (tileSet.name == tileSetName) {
                    return tileSet;
                }
            }
            krew.fwlog("[Error] [TileMapHelper] Tileset not found: " + tileSetName);
            return null;
        }

        /**
         * layer の指定した位置の data を global ID で返す。
         * １枚目のタイル画像の一番左上が gid = 1 となる（タイルなし = 0）
         */
        public static function gidAt(tileLayer:Object, col:uint, row:uint):int {
            var numMapCol:uint = tileLayer.width;
            var tileId:int = tileLayer.data[(row * numMapCol) + col];
            return tileId;
        }

        /**
         * layer の指定した位置の data を local ID で返す
         * 各タイル画像ごとに一番左上を localId = 0 として返す（タイルなし = -1）
         */
        public static function tileAt(tileLayer:Object, tileSet:Object, col:uint, row:uint):int {
            var globalTileId:int = gidAt(tileLayer, col, row);
            if (globalTileId == 0) { return -1; }

            var localTileId:int = globalTileId - tileSet.firstgid;
            if (localTileId < 0) {
                throw new Error("[Error] [TileMapHelper] local id must not be negative. "
                                + "(gid: " + globalTileId + ")");
            }
            return localTileId;
        }

        /**
         * Tiled Map Editor で出力した json による Object を使って、
         * 指定されたマスに対応するテクスチャを持つ Image を返す。
         * orientation: "orthogonal" 専用。spacing に対応.
         *
         * Tiled Map Editor では空タイルは gid = 0 と表現される。
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
            var tileId:int = tileAt(tileLayer, tileSet, col, row);
            if (tileId == -1) { return null; }

            // * consider spacing
            var tileWidth :Number = (tileSet.tilewidth  + tileSet.spacing);
            var tileHeight:Number = (tileSet.tileheight + tileSet.spacing);

            var numTileImageCol:uint = tileSet.imagewidth  / tileWidth;
            var numTileImageRow:uint = tileSet.imageheight / tileHeight;
            var tileImageCol:uint = tileId % numTileImageCol;
            var tileImageRow:uint = tileId / numTileImageCol;

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
