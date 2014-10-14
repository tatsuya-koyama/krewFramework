package krewdemo.scene {

    import flash.ui.Keyboard;

    import krewfw.builtin_actor.ui.ImageButton;

    import krewdemo.GameEvent;
    import krewdemo.GameStatic;
    import krewdemo.actor.common.ScreenFilter;
    import krewdemo.actor.feature_test.*;
    import krewdemo.actor.world_test.*;

    //------------------------------------------------------------
    public class HugeWorldTestScene2 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                 "animation/bird.dbpng"
                ,"image/atlas_world.png"
                ,"image/atlas_world.xml"
            ];
        }

        public override function getLayerList():Array {
            return ['l-back', 'l-ground', 'l-front', 'l-ui', 'l-filter'];
        }

        public override function hookBeforeInit(onComplete:Function):void {
            GameStatic.boneFactories.initFactories(
                ["bird"], onComplete
            );
        }

        public override function initAfterLoad():void {
            _bgColor = 0xffffff;
            super.initAfterLoad();

            setUpActor('l-ground', new HugeWorldTester2());
            setUpActor('l-front',  new BlueBird());
            setUpActor('l-filter', new ScreenFilter(1.0));
            setUpActor('l-ui',     new VirtualJoystick());

            var zoomButton:ImageButton = new ImageButton(
                'red_button', function():void { sendMessage(GameEvent.TRIGGER_ZOOM); },
                50, 50, 60, 60, 440, 210, Keyboard.SPACE
            );
            setUpActor('l-ui', zoomButton);

            var debugViewButton:ImageButton = new ImageButton(
                'red_button', _onClickDebugViewButton,
                50, 50, 60, 60, 440, 130, Keyboard.Z
            );
            setUpActor('l-ui', debugViewButton);

            setUpActor('l-ui', new InfoPopUp(
                  "- Huge world performance test 2.\n"
                + "- (in progress)\n"
                + "\n"
                + "- Arrow: move camera\n"
                + "- Space: change zoom scale\n"
                + "- Z    : toggle debug view\n"
            ));
        }

        private var _debugViewMode:Boolean = true;
        private function _onClickDebugViewButton():void {
            _debugViewMode = !_debugViewMode;
            sendMessage(GameEvent.TOGGLE_DEBUG_VIEW, {debugViewMode: _debugViewMode});
        }

        protected override function onDispose():void {
            GameStatic.boneFactories.dispose();
        }

    }
}
