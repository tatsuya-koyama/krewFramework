package krewfw.core_internal {

    import flash.media.Sound;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import starling.display.Image;
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    /**
     * 特定のスコープにおけるテクスチャ、音、xml, json などのリソースを管理。
     */
    //------------------------------------------------------------
    public class KrewResource {

        private var _assetManager:AssetManager;
        private var _loadedFilePaths:Dictionary;
        private var _scopeName:String;

        //------------------------------------------------------------
        public function KrewResource(scopeName:String="Default") {
            _scopeName = scopeName;

            _assetManager = new KrewConfig.ASSET_MANAGER_CLASS;
            _assetManager.verbose = KrewConfig.ASSET_MANAGER_VERBOSE;

            _loadedFilePaths = new Dictionary();
        }

        //------------------------------------------------------------
        // accessor
        //------------------------------------------------------------

        public function get assetManager():AssetManager {
            return _assetManager;
        }

        public function getTexture(fileName:String):Texture {
            return _assetManager.getTexture(fileName);
        }

        public function getSound(fileName:String):Sound {
            return _assetManager.getSound(fileName);
        }

        public function getXml(fileName:String):XML {
            return _assetManager.getXml(fileName);
        }

        public function getObject(fileName:String):Object {
            return _assetManager.getObject(fileName);
        }

        public function getByteArray(fileName:String):ByteArray {
            return _assetManager.getByteArray(fileName);
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /**
         * シーン単位で使いたいリソースのロード。
         * すでに読み込まれている path を繰り返し指定した場合、
         * 2 回目以降の読み込みはキャンセルされる。
         *
         * 基本的に starling.utils.AssetManager をラップしているだけなので
         * そちらのドキュメントを見よ。
         *
         * <ul>
         *   <li> テクスチャアトラスを読み込む場合は単純に png と xml の 2 つを指定すればよい。
         *        通常、getImage("拡張子を除くファイル名") で取得できる。
         *        画像はファイル名で引くため、読み込まれた全アトラスでソース画像のファイル名
         *        （xml 内の識別子）がユニークになっている必要がある。
         *        （これが嫌な場合は starling.utils.AssetManager を継承して getName を override
         *          したクラスを用意し、それを KrewConfig で指定してほしい）
         *   </li>
         *   <li> mp3  はロード後 getSound()  で取得できる </li>
         *   <li> json も読める。 getObject() で取得できる </li>
         *   <li> xml  も読める。 getXml()    で取得できる </li>
         *
         *   <li> ビットマップフォントは png と fnt を読み込み後、自動的に
         *        starling.text.TextField で使用可能になる
         *   </li>
         * </ul>
         */
        public function loadResources(filePathList:Array, onLoadProgress:Function,
                                      onLoadComplete:Function):void
        {
            for each (var filePath:String in filePathList) {
                if (_loadedFilePaths[filePath]) {
                    _log("[Warning] Asset is already loaded: " + filePath);
                    break;
                }
                _loadedFilePaths[filePath] = true;
                _assetManager.enqueue(filePath);
            }

            _assetManager.loadQueue(function(loadRatio:Number):void {
                if (onLoadProgress != null) {
                    onLoadProgress(loadRatio);
                }
                if (loadRatio == 1) {
                    onLoadComplete();
                }
            });
        }

        public function purge():void {
            _assetManager.purge();
            _loadedFilePaths = new Dictionary();
        }

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function traceResources():void {
            trace('vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv [KrewResource ::', _scopeName + ']');

            var paths:Array = [];
            for (var path:String in _loadedFilePaths) {
                paths.push(path);
            }
            paths.sort();

            var count:int = 1;
            for each (var path:String in paths) {
                var countNum:String = (count < 10) ? (" " + count) : ("" + count);
                trace(" ", countNum + ":", path);
                ++count;
            }

            trace('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^');
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _log(text:String):void {
            krew.fwlog('[KrewResource ::' + _scopeName + '] ' + text);
        }

    }
}
