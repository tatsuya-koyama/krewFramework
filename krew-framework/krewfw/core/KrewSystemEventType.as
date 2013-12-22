package krewfw.core {

    import starling.errors.AbstractClassError;

    public class KrewSystemEventType {

        public function KrewSystemEventType() {
            throw new AbstractClassError();
        }

        /** Dispatched when Flash / AIR is resumed. */
        public static const SYSTEM_ACTIVATE:String   = 'krew.systemActivate';

        /** Dispatched when Flash / AIR is suspended. */
        public static const SYSTEM_DEACTIVATE:String = 'krew.systemDeactivate';

        /** Used by KrewScene. */
        public static const EXIT_SCENE:String = 'krew.exitScene';

        /**
         * Dispatched during scene-scope assets load process
         * (hooked KrewScene.onLoadProgress,)
         * with 'loadRatio' argument between 0.0 to 1.0.
         *
         *     Expected args: {loadRatio: Number}
         */
        public static const PROGRESS_ASSET_LOAD:String = 'krew.progressAssetLoad';

        /** Dispatched when scene-scope assets are loaded. */
        public static const COMPLETE_ASSET_LOAD:String = 'krew.completeAssetLoad';

        /**
         * Dispatched during global-scope assets load process
         * (hooked KrewScene.onLoadProgressGlobal,)
         * with 'loadRatio' argument between 0.0 to 1.0.
         *
         *     Expected args: {loadRatio: Number}
         */
        public static const PROGRESS_GLOBAL_ASSET_LOAD:String = 'krew.progressGlobalAssetLoad';

        /** Dispatched when global-scope assets are loaded. */
        public static const COMPLETE_GLOBAL_ASSET_LOAD:String = 'krew.completeGlobalAssetLoad';

        /** Expected args: {x:Number, y:Number} */
        public static const SCREEN_TOUCH_ANYWAY:String = 'krew.screenTouchAnyway';

        /**
         * Expected args: {x:Number, y:Number,
         *                 touchEvent: starling.events.TouchEvent, touchObj: starling.event.Touch}
         */
        public static const SCREEN_TOUCH_BEGAN:String = 'krew.screenTouchBegan';

        /**
         * Expected args: {x:Number, y:Number,
         *                 touchEvent: starling.events.TouchEvent, touchObj: starling.event.Touch}
         */
        public static const SCREEN_TOUCH_MOVED:String = 'krew.screenTouchMoved';

        /**
         * Expected args: {x:Number, y:Number,
         *                 touchEvent: starling.events.TouchEvent, touchObj: starling.event.Touch}
         */
        public static const SCREEN_TOUCH_ENDED:String = 'krew.screenTouchEnded';

        /** Expected args: {fadeTime:Number, color1:int, color2:int, color3:int, color4:int} */
        public static const CHANGE_BG_COLOR:String = 'krew.changeBgColor';
    }
}
