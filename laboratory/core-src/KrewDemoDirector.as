package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import krewdemo.GameStatic;
    import krewdemo.scene.LoadScene;

    //------------------------------------------------------------
    public class KrewDemoDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function KrewDemoDirector() {
            GameStatic.init();

            var firstScene:KrewScene = new LoadScene();
            startGame(firstScene);
        }

    }
}
