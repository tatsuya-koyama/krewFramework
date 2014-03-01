package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import global_layer.scene.LoadScene;

    //------------------------------------------------------------
    public class GameDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function GameDirector() {
            var firstScene:KrewScene = new LoadScene();
            startGame(firstScene);
        }

        protected override function getGlobalLayerList():Array {
            return ['global-back', 'global-front'];
        }
    }
}
