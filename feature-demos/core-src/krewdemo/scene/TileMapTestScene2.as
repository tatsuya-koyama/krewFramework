package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.ScreenCurtain;
    import krewfw.builtin_actor.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.menu.BackButton;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class TileMapTestScene2 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_game.png"
                ,"image/atlas_game.xml"
                ,"image/atlas_test.png"
                ,"image/atlas_test.xml"
                ,"tilemap/testmap_001.json"
                ,"tilemap/atlas_gbism.png"
            ];
        }

        public override function initAfterLoad():void {
            _bgColor = 0x223322;
            super.initAfterLoad();
            setUpActor('l-front', new TileMapTester2());
            setUpActor('l-ui',    new VirtualJoystick());

            setUpActor('l-ui', new InfoPopUp(
                  "- Large Tile Map test\n"
                + "- 16 QuadBatches\n"
                + "- 256 x 256 tiles\n"
                + "\n"
                + "- Overhead of QuadBatch.addImage() is rather high. "
                + "So I'm trying dynamic load of map display."
                + "\n"
                + "- But caching all map data on the memory is inefficient approach. "
                + "Memory consumption and rendering cost is too high fot mobile devices.",
                "info_icon", "tk_courier", 400
            ));
        }

    }
}
