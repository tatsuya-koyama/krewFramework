package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import krewdemo.GameEvent;
    import krewdemo.actor.title.*;

    //------------------------------------------------------------
    public class TitleScene extends KrewScene {

        private var _loadingBg:ScreenCurtain;

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui', 'l-filter'];
        }

        public override function initAfterLoad():void {
            var color:int = 0x555555;
            setUpActor('l-back', new ScreenCurtain(color, color, color, color));

            setUpActor('l-ui',   new TitleLogo());
            setUpActor('l-ui',   new StartButton());

            blackIn(0.3);

            listen(GameEvent.EXIT_SCENE, onSceneTransition);
        }

        protected function onSceneTransition(args:Object):void {
            blackOut(0.2);
            addScheduledTask(0.2, function():void {
                exit();
            });
        }

        public override function getDefaultNextScene():KrewScene {
            return new MenuScene();
        }
    }
}
