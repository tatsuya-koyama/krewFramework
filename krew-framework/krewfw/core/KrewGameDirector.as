package krewfw.core {

    import starling.display.Sprite;
    import starling.events.Event;

    import krewfw.NativeStageAccessor;

    import flash.display.Stage;
    import flash.events.Event;
    import flash.system.System;
    import krewfw.core_internal.KrewSharedObjects;

    /**
     * Take responsibility for direction of game sequence.
     *   - Switch game scene.
     *   - Call GC on scene transition.
     *   - Pass shared objects to each scene.
     */
    //------------------------------------------------------------
    public class KrewGameDirector extends Sprite {

        private var _currentScene:KrewScene = null;
        private var _sharedObj:KrewSharedObjects = new KrewSharedObjects();

        //------------------------------------------------------------
        public function KrewGameDirector() {
            KrewBlendMode.registerExtendedBlendModes();

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
         * コンストラクタでこれを呼ぶことで、ゲームが始動する.
         * getRequiredGlobalAssets で指定したアセットが読み込まれた後に
         * 最初の scene に遷移
         */
        public function startGame(initialScene:KrewScene):void {
            _loadGlobalAssets(
                getInitialGlobalAssets(),
                function():void {
                    _startScene(initialScene);
                }
            );
        }

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
            _currentScene = scene;

            scene.sharedObj = _sharedObj;
            scene.startInitSceneSequence();

            addChild(scene);
            _currentScene.addEventListener(KrewSystemEventType.EXIT_SCENE, _onExitScene);
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
