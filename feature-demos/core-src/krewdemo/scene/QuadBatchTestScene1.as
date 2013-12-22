package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class QuadBatchTestScene1 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            super.initAfterLoad();
            setUpActor('l-front', new QuadBatchTester1());

            setUpActor('l-ui', new InfoPopUp(
                  "- 2 QuadBatch\n"
                + "- Total 360 Tiles\n"
                + "- Texture resolution: 32 x 32\n"
                + "\n"
                + "- Every frame resets QuadBatch and re-add 360 Images. "
                + "In this bad manner, frame rate drops down on mobile devices..."
            ));
        }

    }
}
