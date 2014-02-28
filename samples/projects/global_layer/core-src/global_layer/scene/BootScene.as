package global_layer.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import global_layer.GameEvent;
    import global_layer.actor.GlobalView;
    import global_layer.actor.SimpleLogo;
    import global_layer.actor.SimpleLogoButton;
    import global_layer.actor.WalkerGenerator;

    //------------------------------------------------------------
    public class BootScene extends KrewScene {

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back', 'l-ui'];
        }

        public override function initAfterLoad():void {
            setUpActor('l-back',   new ScreenCurtain(0x000000));
            setUpActor('l-ui',     new SimpleLogo("BOOT SCENE", 0xcc7777));
            setUpActor('l-ui',     new SimpleLogoButton(GameEvent.EXIT_SCENE, "START GAME"));

            // Add actor to global layer
            setUpActor('global-back', new GlobalView("This is Global Layer", 0xffff66));

            blackIn(0.5);

            listen(GameEvent.EXIT_SCENE, onSceneTransition);
        }

        protected function onSceneTransition(args:Object):void {
            blackOut(0.3);
            addScheduledTask(0.3, function():void {
                exit();
            });
        }

        public override function getDefaultNextScene():KrewScene {
            return new FirstScene();
        }
    }
}
