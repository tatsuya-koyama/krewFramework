package krewasync.scene {

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;

    import krewasync.GameEvent;
    import krewasync.actor.AsyncTaskRunner;
    import krewasync.actor.SimpleLogo;
    import krewasync.actor.SimpleLogoButton;

    //------------------------------------------------------------
    public class MainScene extends KrewScene {

        private var _runButton:SimpleLogoButton;
        private var _totterButton:SimpleLogoButton;

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back', 'l-front', 'l-ui'];
        }

        public override function initAfterLoad():void {
            setUpActor('l-back',  new ScreenCurtain(0x252525, 0x444444, 0x111111, 0x252525));
            setUpActor('l-front', new AsyncTaskRunner());
            setUpActor('l-ui',    new SimpleLogo("ASYNC DEMO", 0xffcc55));

            _runButton = new SimpleLogoButton(
                GameEvent.KICK_RUNNER, "RUN PERFECTLY", 0xffffff, 360, 280, 18
            );
            setUpActor('l-ui', _runButton);

            _totterButton = new SimpleLogoButton(
                GameEvent.KICK_RUNNER_WITH_FAIL, "RUN AND FAIL", 0x99ccff, 110, 280, 18
            );
            setUpActor('l-ui', _totterButton);

            blackIn(0.5);

            listen(GameEvent.KICK_RUNNER, _onStartTasks);
            listen(GameEvent.KICK_RUNNER_WITH_FAIL, _onStartTasks);
            listen(GameEvent.END_ALL_TASK, _onEndAllTasks);
        }

        private function _onStartTasks(args:Object):void {
            _runButton.touchable    = false;
            _runButton.visible      = false;
            _totterButton.touchable = false;
            _totterButton.visible   = false;
        }

        private function _onEndAllTasks(args:Object):void {
            _runButton.touchable    = true;
            _runButton.visible      = true;
            _totterButton.touchable = true;
            _totterButton.visible   = true;
        }

        public override function getDefaultNextScene():KrewScene {
            return new MainScene();
        }
    }
}
