package krewshoot.scene {

    import starling.text.TextField;

    import com.tatsuyakoyama.krewfw.core.KrewScene;
    import com.tatsuyakoyama.krewfw.builtin_actor.ScreenCurtain;

    import krewshoot.GameEvent;
    import krewshoot.actor.common.InterlaceFilter;
    import krewshoot.actor.game.*;

    //------------------------------------------------------------
    public class GameScene extends KrewScene {

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
            var color:int = 0xffffff;
            _loadingBg = new ScreenCurtain(color, color, color, color);
            setUpActor('l-back', _loadingBg);
        }

        public override function onLoadComplete():void {
            _loadingBg.passAway();
        }

        public override function initAfterLoad():void {
            var color:int = 0x555555;
            setUpActor('l-back', new ScreenCurtain(color, color, color, color));

            setUpActor('l-ui',     new NiceLogo());
            setUpActor('l-ui',     new BackButton());
            setUpActor('l-filter', new InterlaceFilter());

            whiteIn(0.5);

            listen(GameEvent.BACK_SCENE, onSceneTransition);
        }

        protected function onSceneTransition(args:Object):void {
            blackOut(0.3);
            addScheduledTask(0.3, function():void {
                exit();
            });
        }

        public override function getDefaultNextScene():KrewScene {
            return new TitleScene();
        }
    }
}
