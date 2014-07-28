package krewfw.core {

    import flash.display.Stage;
    import flash.events.Event;
    import flash.system.System;

    import starling.display.Sprite;
    import starling.events.Event;

    import krewfw.NativeStageAccessor;
    import krewfw.core_internal.KrewSharedObjects;
    import krewfw.utils.krew;

    /**
     * Take responsibility for direction of game sequence.
     *   - Switch game scene.
     *   - Call GC on scene transition.
     *   - Pass shared objects to each scene.
     */
    //------------------------------------------------------------
    public class KrewGameDirector extends Sprite {

        private var _currentScene:KrewScene = null;
        private var _prevScene   :KrewScene = null;

        private var _sharedObj:KrewSharedObjects;
        private var _chapters:Vector.<KrewChapter>;

        //------------------------------------------------------------
        public function KrewGameDirector() {
            _chapters = Vector.<KrewChapter>(getChapterList());

            KrewBlendMode.registerExtendedBlendModes();
            KrewTransition.registerExtendedTransitions();

            var stage:Stage = NativeStageAccessor.stage;
            if (stage != null) {
                stage.addEventListener(flash.events.Event.ACTIVATE,   _onSystemActivate);
                stage.addEventListener(flash.events.Event.DEACTIVATE, _onSystemDeactivate);
            }
        }

        /**
         * ゲーム全体で常に保持しておきたいアセットのファイル名を指定.
         * startScene コール時にこれが読み込まれ、ゲーム中ずっとメモリに保持されることになる。
         * なお、このロードの段階ではローディング画面を作れない（AIR の背景色が表示される）ので
         * ここで指定するものはローディングのアニメーションなど最小限に留め、
         * 本命は起動用 Scene の getRequiredGlobalAssets で指定するとよい
         *
         * @see KrewScene.requiredAssets
         */
        protected function getInitialGlobalAssets():Array {
            return [];
        }

        /**
         * Scene を遷移しても消えないレイヤー構造の定義。
         * これらのレイヤーは最前面に置かれる
         * @return Example: ['global-header', 'global-ui']
         */
        protected function getGlobalLayerList():Array {
            return [];
        }

        /**
         * Scene をまとめて扱う Chapter を定義したい場合は、これを override する。
         * KrewChapter の subclass の instance のリストが返ることを期待。
         * @return Example: [new YourChapterClass()]
         */
        protected function getChapterList():Array {
            return [];
        }

        /**
         * これに最初の Scene を渡して呼ぶことで、ゲームが始動する.
         * krewFramework のセットアップ（KrewConfig の値の変更など）はここまでに済ませておくこと。
         * getInitialGlobalAssets で指定したアセットが読み込まれた後に最初の scene に遷移する
         */
        public function startGame(initialScene:KrewScene):void {
            _sharedObj = new KrewSharedObjects();

            _sharedObj.layerManager.makeGlobalLayers(getGlobalLayerList());

            _loadGlobalAssets(
                getInitialGlobalAssets(),
                function():void {
                    _startScene(initialScene);
                }
            );
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _loadGlobalAssets(fileNameList:Array, onLoadComplete:Function):void {
            if (fileNameList.length == 0) {
                onLoadComplete();
                return;
            }

            _sharedObj.resourceManager.loadGlobalResources(
                fileNameList, null, onLoadComplete
            );
        }

        private function _startScene(scene:KrewScene):void {
            _prevScene    = _currentScene;
            _currentScene = scene;

            _currentScene.sharedObj = _sharedObj;
            _currentScene.setUpLayers();

            _exitChapter(_prevScene, _currentScene);

            _startChapter(
                _prevScene, _currentScene,
                function():void {
                    _currentScene.startInitSceneSequence();
                }
            );

            addChild(_currentScene);
            _currentScene.addEventListener(KrewSystemEventType.EXIT_SCENE, _onExitScene);
        }

        private function _startChapter(prevScene:KrewScene, currentScene:KrewScene,
                                       onComplete:Function):void
        {
            if (_chapters.length == 0) { onComplete(); return; }

            var tasks:Array = [];
            for each (var chapter:KrewChapter in _chapters) {
                var task:Function = chapter.getInitializer(prevScene, currentScene);
                if (task != null) { tasks.push(task); }
            }

            if (tasks.length == 0) { onComplete(); return; }

            krew.async({
                serial: tasks,
                anyway: onComplete
            });
        }

        private function _exitChapter(prevScene:KrewScene, currentScene:KrewScene):void {
            if (_chapters.length == 0) { return; }

            for each (var chapter:KrewChapter in _chapters) {
                chapter.finalize(prevScene, currentScene);
            }
        }

        private function _onSystemActivate(event:flash.events.Event=null):void {
            _sharedObj.notificationService.postMessage(
                KrewSystemEventType.SYSTEM_ACTIVATE, {}
            );
        }

        private function _onSystemDeactivate(event:flash.events.Event=null):void {
            _sharedObj.notificationService.postMessage(
                KrewSystemEventType.SYSTEM_DEACTIVATE, {}
            );
        }

        private function _onExitScene(event:starling.events.Event):void {
            if (!_currentScene) { return; }

            _sharedObj.layerManager.removeGlobalLayersFromScene(_currentScene);

            // Call dispose() of derived KrewScene class and remove listeners.
            // Scene-scope assets will be purged.
            _currentScene.dispose();
            removeChild(_currentScene);

            // go on to the next scene
            var nextScene:KrewScene = _currentScene.getNextScene();
            _startScene(nextScene);

            // call Garbage Collection manually
            System.gc();
        }

    }
}
