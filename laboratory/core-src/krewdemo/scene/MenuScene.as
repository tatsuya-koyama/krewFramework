package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.*;

    //------------------------------------------------------------
    public class MenuScene extends KrewScene {

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui', 'l-filter'];
        }

        public override function initLoadingView():void {
            setUpActor('l-back', new SimpleLoadingScreen(0x000000));
        }

        public override function initAfterLoad():void {
            var color:int = 0x555555;
            setUpActor('l-back', new ScreenCurtain(color, color, color, color));

            setUpActor('l-front', new FeatureMenuList());
            setUpActor('l-ui',    new BackButton());

            blackIn(0.3);

            listen(GameEvent.BACK_SCENE, _onBackScene);
            listen(GameEvent.NEXT_SCENE, _onNextScene);
        }

        private function _onBackScene(args:Object):void {
            blackOut(0.2);
            addScheduledTask(0.2, function():void {
                exit();
            });
        }

        private function _onNextScene(args:Object):void {
            blackOut(0.2);
            addScheduledTask(0.2, function():void {
                exit(args.nextScene);
            });
        }

        public override function getDefaultNextScene():KrewScene {
            return new TitleScene();
        }
    }
}
