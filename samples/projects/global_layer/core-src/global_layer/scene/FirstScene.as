package global_layer.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import global_layer.GameEvent;
    import global_layer.actor.SimpleLogo;
    import global_layer.actor.SimpleLogoButton;
    import global_layer.actor.WalkerGenerator;

    //------------------------------------------------------------
    public class FirstScene extends KrewScene {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            setUpActor('l-back',   new ScreenCurtain(0x252525, 0x444444, 0x111111, 0x252525));

            setUpActor('l-back',   new WalkerGenerator(0.8, 0.4, 0x444444));
            setUpActor('l-middle', new WalkerGenerator(0.6, 0.6, 0x777777));
            setUpActor('l-front',  new WalkerGenerator(0.5, 0.8, 0xaaaaaa));

            setUpActor('l-ui',     new SimpleLogo("FIRST SCENE", 0xffcc55));
            setUpActor('l-ui',     new SimpleLogoButton(GameEvent.EXIT_SCENE, "CHANGE SCENE"));

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
            return new SecondScene();
        }
    }
}
