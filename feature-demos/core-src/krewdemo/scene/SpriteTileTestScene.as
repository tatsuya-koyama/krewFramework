package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class SpriteTileTestScene extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            super.initAfterLoad();
            setUpActor('l-front', new SpriteTileTester());

            setUpActor('l-ui', new InfoPopUp(
                  "- 3 Sprite\n"
                + "- Total 1060 Tiles\n"
                + "- Texture resolution: 32 x 32\n"
                + "\n"
                + "- Using (unflatten) sprite instead of QuadBatch, it's somewhat slower.\n"
                + "\n"
                + "- If call Sprite.flatten(), the performance will be the same as QuadBatch. "
                + "(Actually, flatten method uses QuadBatch internally.)"
            ));
        }

    }
}
