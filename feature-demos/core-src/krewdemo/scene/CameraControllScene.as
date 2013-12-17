package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;

    //------------------------------------------------------------
    public class CameraControllScene extends KrewScene {

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
            var color:int = 0x000000;
            _loadingBg = new ScreenCurtain(color, color, color, color);
            setUpActor('l-back', _loadingBg);
        }

        public override function onLoadComplete():void {
            _loadingBg.passAway();
        }

        public override function initAfterLoad():void {
            var color:int = 0x555555;
            setUpActor('l-back', new ScreenCurtain(color, color, color, color));

            setUpActor('l-ui',   new BackButton(160, 440, 50, 50));

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
