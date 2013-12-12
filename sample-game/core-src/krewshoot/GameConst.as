package krewshoot {

    import starling.errors.AbstractClassError;

    public class GameConst {

        public function GameConst() {
            // prohibit the instantiation of the class
            throw new AbstractClassError();
        }

        // debug config
        public static const FW_LOG_VERBOSE  :int = 1;
        public static const GAME_LOG_VERBOSE:int = 1;

        public static const SHOW_PERFORMANCE:Boolean      = true;
        public static const WATCH_NUM_ACTOR:Boolean       = false;
        public static const ASSET_MANAGER_VERBOSE:Boolean = true;

        // game screen's virtual resolution
        public static const SCREEN_WIDTH:int    = 320;
        public static const SCREEN_HEIGHT:int   = 480;
        public static const ASPECT_RATIO:Number = SCREEN_HEIGHT / SCREEN_WIDTH;

    }
}
