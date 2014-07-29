package krewfw.core {

    import flash.utils.Dictionary;

    import krewfw.utils.krew;
    import krewfw.utils.as3.KrewAsync;

    /**
     * Chapter is group of Scenes.
     *
     * 複数の Scene をまとめたグループを表現する。
     * KrewGameDirector に登録することで、Chapter 単位のリソース読み込みや、
     * Chapter に出入りする際の hook を設定することが可能になる
     */
    //------------------------------------------------------------
    public class KrewChapter {

        private var _sceneClasses:Vector.<Class>;
        private var _requiredAssets:Array;
        private var _footPrints:Dictionary;

        //------------------------------------------------------------
        public function KrewChapter() {
            _sceneClasses   = Vector.<Class>(getSceneClassList());
            _requiredAssets = getRequiredAssets();
            _footPrints     = new Dictionary();
        }

        //------------------------------------------------------------
        // Handlers you override in subclasses
        //------------------------------------------------------------

        /**
         * これを override して、この Chapter を構成する Scene 群を指定する。
         * ゲーム中に使われる KrewScene の Class の配列が返ることを期待。
         */
        protected function getSceneClassList():Array {
            return [];
        }

        /**
         * これを override して、Chapter に入るときに読み込まれるリソースの
         * ファイルパス一覧を指定する。
         * Chapter scope のリソースは Scene scope のリソース読み込みより
         * 先に実行される。
         */
        protected function getRequiredAssets():Array {
            return [];
        }

        /**
         * Chapter の外側から内側に Scene 遷移するとき、
         * Chapter scope のリソース読み込み後、Scene のリソース読み込み前に呼ばれる。
         * override する場合、最後に onComplete を呼ぶことを忘れずに。
         */
        protected function onEnter(onComplete:Function):void {
            onComplete();
        }

        /**
         * Chapter 内から Chapter の外側に Scene 遷移するとき、
         * Scene の dispose の後に呼ばれる。
         */
        protected function onExit():void {}

        /**
         * Chapter に入ってから、初めて遷移する Scene に入るときに呼ばれる。
         * これは Scene のリソース読み込みや初期化よりも先に呼ばれる。
         * override する場合、最後に onComplete を呼ぶことを忘れずに。
         */
        protected function onEnterSceneFirst(scene:KrewScene, onComplete:Function):void {
            onComplete();
        }

        //------------------------------------------------------------
        // Chapter Utilities
        //------------------------------------------------------------

        /**
         * Scene スコープでリソースを読み込む
         */
        protected function loadResources(fileNameList:Array, onLoadProgress:Function,
                                         onLoadComplete:Function):void
        {
            krew.agent.sharedObj.resourceManager.loadResources(
                fileNameList, onLoadProgress, onLoadComplete
            );
        }

        /**
         * Chapter スコープでリソースを読み込む
         */
        protected function loadChapterResources(fileNameList:Array, onLoadProgress:Function,
                                                onLoadComplete:Function):void
        {
            krew.agent.sharedObj.resourceManager.loadChapterResources(
                this, fileNameList, onLoadProgress, onLoadComplete
            );
        }

        //------------------------------------------------------------
        // Called from framework
        //------------------------------------------------------------

        /**
         * @private
         * Chapter の外から Chapter の内側に入ってきたなら、
         * 初期化用の Function を返す。そうでなければ null を返す。
         *
         * 返り値の Function は KrewAsync で使用することを想定している。
         * これは getRequiredAssets で定義されたリソースの読み込みと、
         * onEnter の呼び出しを行う。
         */
        public function getInitializer(prevScene:KrewScene, currentScene:KrewScene):Function {
            // 遷移先が Chapter 内ではない
            if (!_containsScene(currentScene)) { return null; }

            // 前の Scene はすでに Chapter 内だった
            if (_containsScene(prevScene)) { return null; }

            var thisChapter:KrewChapter = this;
            return function(async:KrewAsync):void {
                krew.agent.sharedObj.resourceManager.loadChapterResources(
                    thisChapter, _requiredAssets, null,
                    function():void {
                        onEnter(async.done);
                    }
                );
            };
        }

        /**
         * @private
         * Chapter の内側から Chapter の外に出る場合に、解放処理を呼ぶ
         */
        public function finalize(prevScene:KrewScene, currentScene:KrewScene):void {
            // 遷移先が Chapter の内側
            if (_containsScene(currentScene)) { return; }

            // 外側の Scene から外側の Scene への無関係な遷移だった
            if (!_containsScene(prevScene)) { return; }

            onExit();

            for (var key:* in _footPrints) {
                delete _footPrints[key];
            }

            krew.agent.sharedObj.resourceManager.purgeChapterScopeResources(this);
        }

        /**
         * @private
         * Chapter に入ってから、初めて遷移する Scene であればハンドラを呼ぶ
         */
        public function getOnEnterSceneFirst(currentScene:KrewScene):Function {
            var sceneClass:Class = _findSceneClass(currentScene);
            if (!sceneClass) { return null; }

            if (_footPrints[sceneClass]) { return null; }
            _footPrints[sceneClass] = true;

            return function(async:KrewAsync):void {
                onEnterSceneFirst(currentScene, async.done);
            };
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _containsScene(scene:KrewScene):Boolean {
            if (_sceneClasses.length == 0) { return false; }

            for each (var sceneClass:Class in _sceneClasses) {
                if (scene is sceneClass) {
                    return true;
                }
            }
            return false;
        }

        private function _findSceneClass(scene:KrewScene):Class {
            if (_sceneClasses.length == 0) { return null; }

            for each (var sceneClass:Class in _sceneClasses) {
                if (scene is sceneClass) {
                    return sceneClass;
                }
            }
            return null;
        }

    }
}
