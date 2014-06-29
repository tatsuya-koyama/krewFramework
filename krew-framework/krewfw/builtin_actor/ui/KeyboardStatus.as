package krewfw.builtin_actor.ui {

    import flash.display.Stage;
    import flash.events.KeyboardEvent;

    import krewfw.NativeStageAccessor;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewSystemEventType;

    /**
     * 各キーの押下状態を保持する。
     * flash.ui.Keyboard クラスで定義されている keyCode に対して、
     * KEY_DOWN イベントから KEY_UP イベントまでの間 isPressed は true を返す。
     *
     * また、このクラスは flash.events.KeyboardEvent を krewFramework の
     * イベントに変えて投げる作用も持つ。
     * KeyboardStatus が投げる KrewSystemEventType.KEY_DOWN は Flash のそれと異なり、
     * 押下されたタイミングだけ投げられる（押し続けで発火しない。）
     *
     * ToDo: キーストローク対応
     */
    //------------------------------------------------------------
    public class KeyboardStatus extends KrewActor {

        private var _pressedMap:Object = {};  // {keyCode: <isPressed>}

        public function KeyboardStatus() {
            displayable = false;
        }

        public override function init():void {
            var stage:Stage = NativeStageAccessor.stage;
            stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);
        }

        protected override function onDispose():void {
            var stage:Stage = NativeStageAccessor.stage;
            stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
            stage.removeEventListener(KeyboardEvent.KEY_UP,   _onKeyUp);

            _pressedMap = null;
        }

        public function isPressed(keyCode:int):Boolean {
            return (_pressedMap[keyCode]);
        }

        private function _onKeyDown(event:KeyboardEvent):void {
            if (!isPressed(event.keyCode)) {
                sendMessage(KrewSystemEventType.KEY_DOWN, {keyEvent: event});
            }

            _pressedMap[event.keyCode] = true;
        }

        private function _onKeyUp(event:KeyboardEvent):void {
            sendMessage(KrewSystemEventType.KEY_UP, {keyEvent: event});
            _pressedMap[event.keyCode] = false;
        }

    }
}
