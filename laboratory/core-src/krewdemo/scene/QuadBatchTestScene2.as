package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class QuadBatchTestScene2 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            super.initAfterLoad();
            setUpActor('l-front', new QuadBatchTester2());

            setUpActor('l-ui', new InfoPopUp(
                  "- 2 QuadBatch\n"
                + "- Total 115 Tiles\n"
                + "- Texture resolution: 128 x 128\n"
                + "\n"
                + "- Every frame resets QuadBatch and re-add Images. "
                + "It's not clever, but processing costs are still allowable.\n"
                + "\n"
                + "- In most cases, [Many instances but low resolution] is slower than "
                + "[High resolution but few instances]."
            ));
        }

    }
}
