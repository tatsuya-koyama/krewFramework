package krewfw.core_internal {

    import flash.media.Sound;

    import starling.display.Image;
    import starling.textures.Texture;
    import starling.utils.AssetManager;

    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    //------------------------------------------------------------
    public class KrewResourceManager {

        private var _urlScheme:String;
        private var _globalScopeAssets:AssetManager = new AssetManager();
        private var _sceneScopeAssets :AssetManager = new AssetManager();

        //------------------------------------------------------------
        public function KrewResourceManager() {
            _urlScheme = KrewConfig.ASSET_URL_SCHEME;

            _globalScopeAssets.verbose = KrewConfig.ASSET_MANAGER_VERBOSE;
            _sceneScopeAssets .verbose = KrewConfig.ASSET_MANAGER_VERBOSE;
        }

        //------------------------------------------------------------
        // accessor
        //------------------------------------------------------------

        public function get globalAssetManager():AssetManager {
            return _globalScopeAssets;
        }

        public function get sceneAssetManager():AssetManager {
            return _sceneScopeAssets;
        }

        //------------------------------------------------------------

        /**
         * シーン単位で使いたいリソースのロード.
         * 基本的に starling.utils.AssetManager をラップしているだけなので
         * そちらのドキュメントを見よ。
         *
         * <ul>
         *   <li> テクスチャアトラスを読み込む場合は単純に png と xml の 2 つを指定すればよい。
         *        getImage("拡張子を除くファイル名") で取得できる。
         *        画像はファイル名で引くため、全アトラスでソース画像のファイル名（というか xml 内の識別子）
         *        がユニークになっている必要がある
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
        public function loadResources(fileNameList:Array, onLoadProgress:Function,
                                      onLoadComplete:Function):void
        {
            var suitablePathList:Array = _mapToSuitablePath(fileNameList);
            _sceneScopeAssets.enqueue(suitablePathList);

            _sceneScopeAssets.loadQueue(function(loadRatio:Number):void {
                if (onLoadProgress != null) {
                    onLoadProgress(loadRatio);
                }
                if (loadRatio == 1) {
                    onLoadComplete();
                }
            });
        }

        /**
         * シーン遷移時にこれを呼んでメモリ解放（テクスチャの dispose を呼ぶ）
         */
        public function purgeSceneScopeResources():void {
            _sceneScopeAssets.purge();
        }

        /**
         * ゲームを通してずっとメモリに保持しておくリソースのロード.
         * （Loading 画面のアセットなど）
         * 使い方は loadResources と同じ。
         * ロードしたものの取得は getGlobalImage() などと Global がついたメソッドで。
         *
         * 現状はゲームの起動時に 1 回実行することを想定。
         */
        public function loadGlobalResources(fileNameList:Array, onLoadProgress:Function,
                                            onLoadComplete:Function):void
        {
            var suitablePathList:Array = _mapToSuitablePath(fileNameList);
            _globalScopeAssets.enqueue(suitablePathList);

            _globalScopeAssets.loadQueue(function(loadRatio:Number):void {
                if (onLoadProgress != null) {
                    onLoadProgress(loadRatio);
                }
                if (loadRatio == 1) {
                    onLoadComplete();
                }
            });
        }

        //------------------------------------------------------------
        // getters for game resources
        //------------------------------------------------------------

        /**
         * 拡張子無しのファイル名を指定。シーンスコープのアセットから検索し、
         * 見つからなければグローバルスコープのアセットから検索して返す。
         * （他の getter でも同様）
         */
        public function getImage(fileName:String):Image {
            var texture:Texture = getTexture(fileName);
            if (texture) { return new Image(texture); }

            krew.fwlog('[Error] [KRM] Image not found: ' + fileName);
            return null;
        }

        public function getTexture(fileName:String):Texture {
            var texture:Texture = _sceneScopeAssets.getTexture(fileName);
            if (texture) { return texture; }

            texture = _globalScopeAssets.getTexture(fileName);
            if (texture) { return texture; }

            krew.fwlog('[Error] [KRM] Texture not found: ' + fileName);
            return null;
        }

        public function getSound(fileName:String):Sound {
            var sound:Sound = _sceneScopeAssets.getSound(fileName);
            if (sound) { return sound; }

            sound = _globalScopeAssets.getSound(fileName);
            if (sound) { return sound; }

            krew.fwlog('[Error] [KRM] Sound not found: ' + fileName);
            return null;
        }

        public function getXml(fileName:String):XML {
            var xml:XML = _sceneScopeAssets.getXml(fileName);
            if (xml) { return xml; }

            xml = _globalScopeAssets.getXml(fileName);
            if (xml) { return xml; }

            krew.fwlog('[Error] [KRM] XML not found: ' + fileName);
            return null;
        }

        public function getObject(fileName:String):Object {
            var obj:Object = _sceneScopeAssets.getObject(fileName);
            if (obj) { return obj; }

            obj = _globalScopeAssets.getObject(fileName);
            if (obj) { return obj; }

            krew.fwlog('[Error] [KRM] Object not found: ' + fileName);
            return null;


            return _sceneScopeAssets.getObject(fileName);
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------
        private function _mapToSuitablePath(fileNameList:Array):Array {
            var suitablePathList:Array = [];
            for each (var fileName:String in fileNameList) {
                suitablePathList.push(
                    _urlScheme + KrewConfig.ASSET_BASE_PATH + fileName
                );
            }
            return suitablePathList;
        }

    }
}
