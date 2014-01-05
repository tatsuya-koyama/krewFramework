package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class NapePhysicsTestScene2 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_game.png"
                ,"image/atlas_game.xml"
            ];
        }

        public override function initAfterLoad():void {
            _bgColor = 0x444444;
            super.initAfterLoad();

            setUpActor('l-front', new NapePhysicsTester2());
            setUpActor('l-ui',    new VirtualJoystick());

            setUpActor('l-ui', new InfoPopUp(
                  "- Nape physics test 2\n"
                + "- Testing performance",
                "info_icon", "tk_courier", 400
            ));
        }

    }
}
