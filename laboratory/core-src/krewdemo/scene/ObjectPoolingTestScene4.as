package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class ObjectPoolingTestScene4 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            _bgColor = 0x111127;
            super.initAfterLoad();

            setUpActor('l-front', new ObjectPoolingTester4());

            setUpActor('l-ui', new InfoPopUp(
                  "- Object pooling memory consumption test ver.3.\n"
                + "- This scene is using pooling.\n"
                + "- Using KrewPoolable Actor.\n"
            ));
        }

        protected override function onDispose():void {
            trace(' =================== scene dispose');
            StarParticlePooled3.disposePool();
        }

    }
}
