package krewfw.utils.dev_tool {

    import krewfw.core.KrewGameDirector;
    import krewfw.core.KrewScene;

    /**
     * Utilities for unit test.
     */
    //------------------------------------------------------------
    public class KrewTestUtil {

        /**
         * Return test-ready scene instance.
         *
         * Usage:
         * <pre>
         *     var scene:KrewScene = KrewTestUtil.getScene();
         *     scene.setUpActor(null, new KrewActor());  // use default layer name
         *     scene.mainLoop();
         *     ...
         * </pre>
         */
        public static function getScene():KrewScene {
            var director:KrewGameDirector = new KrewGameDirector();
            var scene:KrewScene = new KrewScene();
            director.startGame(scene);

            return scene;
        }

    }
}
