package global_layer.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import global_layer.GameEvent;
    import global_layer.actor.SimpleLogo;
    import global_layer.actor.SimpleLogoButton;

    //------------------------------------------------------------
    public class SecondScene extends KrewScene {

        private const DEL_GLOBAL_BACK:String = "delGlobalBack";

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui'];
        }

        public override function initAfterLoad():void {
            setUpActor('l-back', new ScreenCurtain(0x222233, 0x444466, 0x111122, 0x222233));
            setUpActor('l-ui',   new SimpleLogo("SECOND SCENE", 0x99ccff));
            setUpActor('l-ui',   new SimpleLogoButton(GameEvent.EXIT_SCENE, "BACK SCENE"));

            setUpActor('l-ui', new SimpleLogoButton(
                DEL_GLOBAL_BACK, "Dispose Global-Back Layer", 0xff9999, 360, 30, 14
            ));

            blackIn(0.5);

            listen(GameEvent.EXIT_SCENE, onSceneTransition);
            listen(DEL_GLOBAL_BACK, onDisposeGlobalBackLayer);
        }

        protected function onSceneTransition(args:Object):void {
            blackOut(0.3);
            addScheduledTask(0.3, function():void {
                exit();
            });
        }

        protected function onDisposeGlobalBackLayer(args:Object):void {
            sharedObj.layerManager.killActors("global-back");
        }

        public override function getDefaultNextScene():KrewScene {
            return new FirstScene();
        }
    }
}
