package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class CreateActorTestScene extends FeatureTestSceneBase {

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

            setUpActor('l-front', new CreateActorTester());

            setUpActor('l-ui', new InfoPopUp(
                  "- krewFramework actor-system memory consumption test\n"
            ));
        }

    }
}
