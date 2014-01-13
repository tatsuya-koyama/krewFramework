package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class TileMapTestScene1 extends FeatureTestSceneBase {

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
            setUpActor('l-front', new TileMapTester1());
            setUpActor('l-ui',    new VirtualJoystick());

            setUpActor('l-ui', new InfoPopUp(
                  "- First step of Tile Map test\n"
                + "- 1 QuadBatch\n"
                + "- 70 x 54 tiles"
                + "\n"
                + "- Simply displays small QuadBatch. It's not scalable yet.",
                "info_icon", "tk_courier", 400
            ));
        }

    }
}
