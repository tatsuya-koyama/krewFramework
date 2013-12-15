package {

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Rectangle;

    import krewshoot.GameConst;

    import starling.core.Starling;

    import krewfw.KrewConfig;
    import krewfw.NativeStageAccessor;

    /**
     * The entry point of the game.
     */
    //------------------------------------------------------------
    public class Main extends Sprite {

        private var _starling:Starling;
        private var _rootSprite:Sprite;

        //------------------------------------------------------------
        public function Main(rootSprite:Sprite) {
            _rootSprite = rootSprite;
            _initTkFramework();
            _initStarling();
            _rootSprite.stage.addEventListener(Event.RESIZE, _onResizeStage);
        }

        private function _initTkFramework():void {
            KrewConfig.FW_LOG_VERBOSE        = GameConst.FW_LOG_VERBOSE;
            KrewConfig.GAME_LOG_VERBOSE      = GameConst.GAME_LOG_VERBOSE;
            KrewConfig.ASSET_MANAGER_VERBOSE = GameConst.ASSET_MANAGER_VERBOSE;
            KrewConfig.WATCH_NUM_ACTOR       = GameConst.WATCH_NUM_ACTOR;
            KrewConfig.SCREEN_WIDTH          = GameConst.SCREEN_WIDTH;
            KrewConfig.SCREEN_HEIGHT         = GameConst.SCREEN_HEIGHT;

            NativeStageAccessor.stage = _rootSprite.stage;
        }

        /**
         * Set viewport and start Starling framework.
         */
        private function _initStarling():void {
            // set general properties
            _rootSprite.stage.scaleMode = StageScaleMode.NO_SCALE;
            _rootSprite.stage.align     = StageAlign.TOP_LEFT;

            Starling.multitouchEnabled = true;  // useful on mobile devices
            Starling.handleLostContext = true;  // required on Android

            // set up Starling
            var viewPort:Rectangle = new Rectangle(
                0, 0, GameConst.SCREEN_WIDTH, GameConst.SCREEN_HEIGHT
            );
            _starling = new Starling(KrewShootDirector, _rootSprite.stage, viewPort);
            _starling.simulateMultitouch = true;
            _starling.start();
            _onResizeStage();

            if (GameConst.SHOW_PERFORMANCE) {
                _starling.showStats = true;
            }
        }

        /**
         * Create a suitable viewport for the screen size.
         */
        private function _getViewPort():Rectangle {
            var screenWidth:int    = _rootSprite.stage.stageWidth;
            var screenHeight:int   = _rootSprite.stage.stageHeight;
            var viewPort:Rectangle = new Rectangle();

            if (screenHeight / screenWidth < GameConst.ASPECT_RATIO) {
                viewPort.height = screenHeight;
                viewPort.width  = int(viewPort.height / GameConst.ASPECT_RATIO);
                viewPort.x = int((screenWidth - viewPort.width) / 2);
            } else {
                viewPort.width  = screenWidth;
                viewPort.height = int(viewPort.width * GameConst.ASPECT_RATIO);
                viewPort.y = int((screenHeight - viewPort.height) / 2);
            }

            trace("stageWidth : " + _rootSprite.stage.stageWidth);
            trace("stageHeight: " + _rootSprite.stage.stageHeight);
            trace(viewPort);

            return viewPort;
        }

        private function _onResizeStage(event:Event=null):void {
            trace("Resized stage.");
            _starling.viewPort = _getViewPort();
        }
    }

}
