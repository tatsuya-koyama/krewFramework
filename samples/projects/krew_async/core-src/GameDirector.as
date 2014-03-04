package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import krewasync.scene.LoadScene;

    //------------------------------------------------------------
    public class GameDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function GameDirector() {
            var firstScene:KrewScene = new LoadScene();
            startGame(firstScene);
        }

    }
}
