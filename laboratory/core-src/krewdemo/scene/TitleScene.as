package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import krewdemo.GameEvent;
    import krewdemo.actor.common.ScreenFilter;
    import krewdemo.actor.title.*;

    //------------------------------------------------------------
    public class TitleScene extends KrewScene {

        private var _loadingBg:ScreenCurtain;

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_filter.png"
                ,"image/atlas_filter.xml"
            ];
        }

        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui', 'l-filter'];
        }

        public override function initAfterLoad():void {
            setUpActor('l-back',   new ScreenCurtain(0xcce877));
            setUpActor('l-front',  new TileEffect());
            setUpActor('l-ui',     new TitleLogo());
            setUpActor('l-ui',     new StartButton());
            setUpActor('l-ui',     new ToggleStatsButton());
            setUpActor('l-filter', new ScreenFilter());

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
