package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import krewdemo.scene.LoadScene;

    //------------------------------------------------------------
    public class KrewDemoDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function KrewDemoDirector() {
            var firstScene:KrewScene = new LoadScene();
            startGame(firstScene);
        }

    }
}
