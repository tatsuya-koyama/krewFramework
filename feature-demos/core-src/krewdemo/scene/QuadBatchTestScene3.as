package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class QuadBatchTestScene3 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            super.initAfterLoad();
            setUpActor('l-front', new QuadBatchTester3());

            setUpActor('l-ui', new InfoPopUp(
                  "- 3 QuadBatch\n"
                + "- Total 1060 Tiles\n"
                + "- Texture resolution: 32 x 32\n"
                + "\n"
                + "- QuadBatches are initialized only once. It's very fast. "
                + "It can keep 60 FPS even on mobile devices."
            ));
        }

    }
}
