package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import global_layer.scene.BootScene;

    //------------------------------------------------------------
    public class GameDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function GameDirector() {
            var firstScene:KrewScene = new BootScene();
            startGame(firstScene);
        }

        protected override function getInitialGlobalAssets():Array {
            return [
                 'bmp_font/tk_cooper.png'
                ,'bmp_font/tk_cooper.fnt'
                ,"image/atlas_game.png"
                ,"image/atlas_game.xml"
            ];
        }

        protected override function getGlobalLayerList():Array {
            return ['global-back', 'global-front'];
        }
    }
}
