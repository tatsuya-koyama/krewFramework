package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class TileMapTestScene3 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "tilemap/testmap_001.json"
                ,"tilemap/atlas_gbism.png"
            ];
        }

        public override function initLoadingView():void {
            setUpActor('l-back', new SimpleLoadingScreen(0x333333, true));
        }

        public override function initAfterLoad():void {
            _bgColor = 0x223322;
            super.initAfterLoad();
            setUpActor('l-front', new TileMapTester3());
            setUpActor('l-ui',    new VirtualJoystick());

            setUpActor('l-ui', new InfoPopUp(
                  "- Tile Map Collision Test\n"
                + "- You can also use keyboard. Arrow keys to move.",
                "info_icon", "tk_courier", 400
            ));
        }

    }
}
