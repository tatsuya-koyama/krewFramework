package krewdemo.scene {

    import flash.ui.Keyboard;

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ImageButton;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class TileMapTestScene4 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_game.png"
                ,"image/atlas_game.xml"
                ,"tilemap/testmap_001.json"
                ,"tilemap/atlas_gbism.png"
            ];
        }

        public override function initAfterLoad():void {
            _bgColor = 0x223322;
            _backButtonY = 30;
            super.initAfterLoad();

            setUpActor('l-front', new TileMapTester4());
            setUpActor('l-ui',    new VirtualJoystick());

            var jumpButton:ImageButton = new ImageButton(
                'red_button', function():void { sendMessage(GameEvent.TRIGGER_JUMP); },
                64, 64, 80, 80, 420, 270, Keyboard.SPACE
            );
            setUpActor('l-ui', jumpButton);

            setUpActor('l-ui', new InfoPopUp(
                  "- Tile Map Collision Test with gravity\n"
                + "- You can also use keyboard.\n"
                + "- Arrow keys to move, and Space key to jump the character (He can double jump.)",
                "info_icon", "tk_courier", 400, 30
            ));
        }

    }
}
