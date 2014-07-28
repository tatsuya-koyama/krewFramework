package krewfw.core_internal {

    import krewfw.KrewConfig;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewSystemEventType;

    //------------------------------------------------------------
    public class SceneServantActor extends KrewActor {

        private var _isSystemActivated:Boolean = true;

        //------------------------------------------------------------
        public function get isSystemActivated():Boolean {
            return _isSystemActivated;
        }

        //------------------------------------------------------------
        public override function init():void {
            listen(KrewSystemEventType.SYSTEM_ACTIVATE,   _onSystemActivate);
            listen(KrewSystemEventType.SYSTEM_DEACTIVATE, _onSystemDeactivate);

            //--- for debug: set profiling task
            if (KrewConfig.WATCH_NUM_ACTOR) {
                addPeriodicTask(1.0, ProfileData.traceNumActor);
            }

            if (KrewConfig.WATCH_LOADED_RESOURCES) {
                addPeriodicTask(2.0, sharedObj.resourceManager.traceResources);
            }
        }

        private function _onSystemActivate(args:Object):void {
            _isSystemActivated = true;
            resumeBgm();
        }

        private function _onSystemDeactivate(args:Object):void {
            _isSystemActivated = false;
            pauseBgm();
        }
    }
}
