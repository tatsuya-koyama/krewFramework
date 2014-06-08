package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class ObjectPoolingTestScene3 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            _bgColor = 0x111127;
            super.initAfterLoad();

            setUpActor('l-front', new ObjectPoolingTester3());

            setUpActor('l-ui', new InfoPopUp(
                  "- Object pooling memory consumption test ver.2.\n"
                + "- This scene is using pooling.\n"
                + "- Using KrewObjectPool utility class.\n"
            ));
        }

        protected override function onDispose():void {
            trace(' =================== scene dispose');
            StarParticlePooled2.disposePool();
        }

    }
}
