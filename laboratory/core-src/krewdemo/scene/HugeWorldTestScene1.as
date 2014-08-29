package krewdemo.scene {

    import krewdemo.actor.common.ScreenFilter;
    import krewdemo.actor.feature_test.*;

    //------------------------------------------------------------
    public class HugeWorldTestScene1 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_world.png"
                ,"image/atlas_world.xml"
            ];
        }

        public override function initAfterLoad():void {
            _bgColor = 0xffffff;
            super.initAfterLoad();

            setUpActor('l-filter', new ScreenFilter(1.0));

            setUpActor('l-ui', new InfoPopUp(
                  "- Huge world performance test.\n"
                + "- (in progress)\n"
            ));
        }

    }
}
