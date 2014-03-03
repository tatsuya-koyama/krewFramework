package krewdemo.scene {

    import flash.ui.Keyboard;

    import starling.text.TextField;

    import krewfw.builtin_actor.ui.ImageButton;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;
    import krewfw.core.KrewScene;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class PlatformerTestScene1 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "tilemap/testmap_001.json"
                ,"tilemap/atlas_gbism.png"
                ,"levelmap/level_1.json"
            ];
        }

        public override function initLoadingView():void {
            setUpActor('l-back', new SimpleLoadingScreen(0x333333, true));
        }

        public override function initAfterLoad():void {
            _bgColor = 0x338899;
            _backButtonY = 30;
            super.initAfterLoad();

            setUpActor('l-front', new PlatformerTester1());
            setUpActor('l-ui',    new VirtualJoystick());

            var jumpButton:ImageButton = new ImageButton(
                'red_button', function():void { sendMessage(GameEvent.TRIGGER_JUMP); },
                64, 64, 80, 80, 420, 270, Keyboard.SPACE
            );
            setUpActor('l-ui', jumpButton);

            setUpActor('l-ui', new InfoPopUp(
                  "- Not-Tile based Platformer Test\n"
                + "- You can also use keyboard. Arrow keys to move.",
                "info_icon", "tk_courier", 400, 30
            ));
        }

    }
}
