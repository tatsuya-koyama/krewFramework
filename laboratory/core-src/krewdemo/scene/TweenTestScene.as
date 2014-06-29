package krewdemo.scene {

    import starling.text.TextField;

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    import krewdemo.GameEvent;
    import krewdemo.actor.common.ScreenFilter;
    import krewdemo.actor.feature_test.*;
    import krewdemo.actor.title.TileEffect;

    //------------------------------------------------------------
    public class TweenTestScene extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "image/atlas_filter.png"
                ,"image/atlas_filter.xml"
            ];
        }

        public override function initAfterLoad():void {
            _bgColor = 0x386611;
            super.initAfterLoad();

            setUpActor('l-front',  new TileEffect());
            setUpActor('l-filter', new ScreenFilter());

            setUpActor('l-ui', new InfoPopUp(
                  "- Actor's Tween test.\n"
            ));
        }

    }
}
