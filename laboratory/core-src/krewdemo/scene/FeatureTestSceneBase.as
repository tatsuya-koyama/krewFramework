package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;

    //------------------------------------------------------------
    public class FeatureTestSceneBase extends KrewScene {

        protected var _bgColor:int = 0x555555;
        protected var _backButtonX:Number = 450;
        protected var _backButtonY:Number = 290;

        private var _loadingBg:ScreenCurtain;

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_game.png"
                ,"image/atlas_game.xml"
            ];
        }

        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui', 'l-filter'];
        }

        public override function initLoadingView():void {
            setUpActor('l-back', new SimpleLoadingScreen(0x000000));
        }

        public override function initAfterLoad():void {
            setUpActor('l-back',  new ScreenCurtain(_bgColor, _bgColor, _bgColor, _bgColor));
            setUpActor('l-ui',    new BackButton(_backButtonX, _backButtonY));

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
            return new MenuScene();
        }
    }
}
