package krewfw.core_internal {

    import flash.media.Sound;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;

    import starling.display.Image;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;
    import starling.utils.AssetManager;

    import krewfw.KrewConfig;
    import krewfw.core.KrewChapter;
    import krewfw.utils.krew;

    /**
     * Scene, Chapter, Global の 3 種類のスコープでリソースを管理する。
     */
    //------------------------------------------------------------
    public class KrewResourceManager {

        private var _sceneResource:KrewResource;
        private var _globalResource:KrewResource;
        private var _chapterResources:Dictionary;
        private var _numActiveChapter:int = 0;

        private var _urlResolverHook:Function = null;

        //------------------------------------------------------------
        public function KrewResourceManager() {
            _sceneResource  = new KrewResource("Scene");
            _globalResource = new KrewResource("Global");
            _chapterResources = new Dictionary();
        }

        //------------------------------------------------------------
        // accessor
        //------------------------------------------------------------

        public function get globalAssetManager():AssetManager {
            return _globalResource.assetManager;
        }

        public function get sceneAssetManager():AssetManager {
            return _sceneResource.assetManager;
        }

        //------------------------------------------------------------
        // load and purge
        //------------------------------------------------------------

        /**
         * シーン単位で使いたいリソースのロード。シーン遷移時に破棄される。
         * KrewResource および starling.utils.AssetManager のドキュメントを見よ。
         */
        public function loadResources(fileNameList:Array, onLoadProgress:Function,
                                      onLoadComplete:Function):void
        {
            var suitablePathList:Array = _mapToSuitablePath(fileNameList);
            _sceneResource.loadResources(suitablePathList, onLoadProgress, onLoadComplete);
        }

        /**
         * シーン遷移時に krewFramework がこれを呼んでメモリ解放する
         * （テクスチャの dispose を呼ぶ）
         */
        public function purgeSceneScopeResources():void {
            _sceneResource.purge();
        }

        /**
         * ゲームを通してずっとメモリに保持しておくリソースのロード。
         * （Loading 画面のアセットなど）
         * 使い方は loadResources と同じ。
         * Scene スコープのものと同様に、getImage() などで取得できる。
         * （同じキーのものが両方にある場合、Scene スコープのものが優先される）
         *
         * KrewGameDirector の getInitialGlobalAssets を override するか、
         * KrewScene の getAdditionalGlobalAssets を override することで、
         * フレームワークが内部的に呼ぶ。
         * （krewFramework の利用者は直接この関数を呼ぶべきではない）
         */
        public function loadGlobalResources(fileNameList:Array, onLoadProgress:Function,
                                            onLoadComplete:Function):void
        {
            var suitablePathList:Array = _mapToSuitablePath(fileNameList);
            _globalResource.loadResources(suitablePathList, onLoadProgress, onLoadComplete);
        }

        /**
         * Scene を複数まとめた Chapter スコープで保持しておきたいリソースのロード。
         * KrewChapter を KrewGameDirector に登録することによって、フレームワークが内部的に呼ぶ。
         * （krewFramework の利用者は直接この関数を呼ぶべきではない。
         *   Scene の途中で動的に読み込みを行いたい場合には KrewChapter のインタフェースを通して呼ぶ）
         */
        public function loadChapterResources(chapter:KrewChapter,
                                             fileNameList:Array, onLoadProgress:Function,
                                             onLoadComplete:Function):void
        {
            if (_chapterResources[chapter]) {
                krew.fwlog("[Error] [KRM] Chapter-scope resources are already exists.");
                krew.fwlog('   - class: ' + getQualifiedClassName(chapter));
            }

            var resource:KrewResource = new KrewResource("Chapter");
            _chapterResources[chapter] = resource;
            ++_numActiveChapter;

            var suitablePathList:Array = _mapToSuitablePath(fileNameList);
            resource.loadResources(suitablePathList, onLoadProgress, onLoadComplete);
        }

        /**
         * Chapter スコープのリソースを破棄。
         * この関数は krewFramework が内部的に呼ぶ。
         * （krewFramework の利用者は直接この関数を呼ぶべきではない）
         */
        public function purgeChapterScopeResources(chapter:KrewChapter):void {
            if (!_chapterResources[chapter]) {
                krew.fwlog("[Error] [KRM] Chapter-scope resources not found.");
                krew.fwlog('   - class: ' + getQualifiedClassName(chapter));
                return;
            }

            var resource:KrewResource = _chapterResources[chapter];
            resource.purge();
            delete _chapterResources[chapter];
            --_numActiveChapter;
        }

        //------------------------------------------------------------
        // getters for game resources
        //------------------------------------------------------------

        /**
         * ロード済みの画像アセットをもとに、Image を作って返す。
         * 拡張子無しのファイル名を指定。Scene スコープのアセットから検索し、
         * 見つからなければ Chapter スコープ、Global スコープの順で検索して返す。
         * （他の getter でも同様）
         */
        public function getImage(fileName:String):Image {
            var texture:Texture = getTexture(fileName);
            if (texture) { return new Image(texture); }

            krew.fwlog('[Error] [KRM] Image not found: ' + fileName);
            return null;
        }

        /** ロード済みの Texture を返す */
        public function getTexture(fileName:String):Texture {
            var texture:Texture = _sceneResource.getTexture(fileName);
            if (texture) { return texture; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    texture = chapterResource.getTexture(fileName);
                    if (texture) { return texture; }
                }
            }

            texture = _globalResource.getTexture(fileName);
            if (texture) { return texture; }

            krew.fwlog('[Error] [KRM] Texture not found: ' + fileName);
            return null;
        }

        /** ロード済みの TextureAtlas を返す */
        public function getTextureAtlas(fileName:String):TextureAtlas {
            var textureAtlas:TextureAtlas = _sceneResource.getTextureAtlas(fileName);
            if (textureAtlas) { return textureAtlas; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    textureAtlas = chapterResource.getTextureAtlas(fileName);
                    if (textureAtlas) { return textureAtlas; }
                }
            }

            textureAtlas = _globalResource.getTextureAtlas(fileName);
            if (textureAtlas) { return textureAtlas; }

            krew.fwlog('[Error] [KRM] TextureAtlas not found: ' + fileName);
            return null;
        }

        /** ロード済みの Sound を返す */
        public function getSound(fileName:String):Sound {
            var sound:Sound = _sceneResource.getSound(fileName);
            if (sound) { return sound; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    sound = chapterResource.getSound(fileName);
                    if (sound) { return sound; }
                }
            }

            sound = _globalResource.getSound(fileName);
            if (sound) { return sound; }

            krew.fwlog('[Error] [KRM] Sound not found: ' + fileName);
            return null;
        }

        /** ロード済みの XML を返す */
        public function getXml(fileName:String):XML {
            var xml:XML = _sceneResource.getXml(fileName);
            if (xml) { return xml; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    xml = chapterResource.getXml(fileName);
                    if (xml) { return xml; }
                }
            }

            xml = _globalResource.getXml(fileName);
            if (xml) { return xml; }

            krew.fwlog('[Error] [KRM] XML not found: ' + fileName);
            return null;
        }

        /** ロード済みの JSON を返す */
        public function getObject(fileName:String):Object {
            var obj:Object = _sceneResource.getObject(fileName);
            if (obj) { return obj; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    obj = chapterResource.getObject(fileName);
                    if (obj) { return obj; }
                }
            }

            obj = _globalResource.getObject(fileName);
            if (obj) { return obj; }

            krew.fwlog('[Error] [KRM] Object not found: ' + fileName);
            return null;
        }

        /** ロード済みの ByteArray を返す */
        public function getByteArray(fileName:String):ByteArray {
            var byteArray:ByteArray = _sceneResource.getByteArray(fileName);
            if (byteArray) { return byteArray; }

            if (_numActiveChapter > 0) {
                for each (var chapterResource:KrewResource in _chapterResources) {
                    byteArray = chapterResource.getByteArray(fileName);
                    if (byteArray) { return byteArray; }
                }
            }

            byteArray = _globalResource.getByteArray(fileName);
            if (byteArray) { return byteArray; }

            krew.fwlog('[Error] [KRM] ByteArray not found: ' + fileName);
            return null;
        }

        /**
         * 現環境におけるアセットファイルの URL を取得する
         * （fileName の先頭に KrewConfig で指定した URL スキームと、
         *   ベースパスを足したものを返す。）
         *
         * fileName にコロン (:) が含まれていた場合はすでに URL スキームが
         * 指定されているものと見なして、そのまま fileName を返す
         */
        public function getURL(fileName:String):String {
            if (_urlResolverHook != null) {
                fileName = _urlResolverHook(fileName);
            }

            if (fileName.indexOf(":") != -1) {
                return fileName;
            }

            return KrewConfig.ASSET_URL_SCHEME + KrewConfig.ASSET_BASE_PATH + fileName;
        }

        /**
         * getURL に渡す fileName を差し替えるフックを設定する
         *
         * @param hook function(fileName:String):String ... 新しい fileName を返す関数
         */
        public function setURLResolverHook(hook:Function):void {
            _urlResolverHook = hook;
        }

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function traceResources():void {
            trace("");
            _sceneResource.traceResources();
            for (var chapter:* in _chapterResources) {
                _chapterResources[chapter].traceResources(
                    "Chapter (" + getQualifiedClassName(chapter) + ")"
                );
            }
            _globalResource.traceResources();
            trace("");
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------
        private function _mapToSuitablePath(fileNameList:Array):Array {
            var suitablePathList:Array = [];
            for each (var fileName:String in fileNameList) {
                suitablePathList.push(getURL(fileName));
            }
            return suitablePathList;
        }

    }
}
