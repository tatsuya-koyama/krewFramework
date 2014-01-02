package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
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
            super.initAfterLoad();
            setUpActor('l-front', new TileMapTester4());
            setUpActor('l-ui',    new VirtualJoystick());

            setUpActor('l-ui', new InfoPopUp(
                  "- Tile Map Collision Test with gravity\n"
                + "- You can also use keyboard.\n"
                + "- Hit KeyUp to jump the character (He can double jump.)",
                "info_icon", "tk_courier", 400
            ));
        }

    }
}
