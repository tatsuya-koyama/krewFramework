package krewdemo.actor.world_test {

    import starling.text.TextField;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.core_internal.StageLayer;
    import krewfw.utils.starling.TextFactory;

    import krewdemo.GameConst;
    import krewdemo.GameEvent;

    //------------------------------------------------------------
    public class WorldCameraPrototype extends KrewActor {

        private var _layer:StageLayer;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        private var _zoomScale:Number = 1.0;
        private var _targetZoomScale:Number = 1.0;

        private var _textField:TextField;

        //------------------------------------------------------------
        public function WorldCameraPrototype() {
            displayable = false;
        }

        public override function init():void {
            _layer = getLayer(layerName);

            var actor:KrewActor = new KrewActor();
            _textField = _makeText("x, y: ");
            actor.addText(_textField, 58, 5);
            createActor(actor, 'l-ui');

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
            listen(GameEvent.TRIGGER_ZOOM, _onZoom);
        }

        private function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX;
            _velocityY = args.velocityY;
        }

        private function _onZoom(args:Object):void {
            switch (_targetZoomScale) {
                case 1.00: _targetZoomScale = 0.50; break;
                case 0.50: _targetZoomScale = 0.25; break;
                case 0.25: _targetZoomScale = 0.10; break;
                default  : _targetZoomScale = 1.00; break;
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _focusX += (300 * -_velocityX) * passedTime;
            _focusY += (300 * -_velocityY) * passedTime;

            _zoomScale += (_targetZoomScale - _zoomScale) * 2.0 * passedTime;

            _updateViewport();
        }

        private function _updateViewport():void {
            _layer.x = _focusX * _zoomScale + (GameConst.SCREEN_WIDTH  / 2);
            _layer.y = _focusY * _zoomScale + (GameConst.SCREEN_HEIGHT / 2);

            _layer.scaleX = _zoomScale;
            _layer.scaleY = _zoomScale;

            _textField.text = "x, y: " + Math.round(_layer.x)
                                + ", " + Math.round(_layer.y);
        }

        private function _makeText(str:String="", fontName:String="tk_courier"):TextField {
            var text:TextField = TextFactory.makeText(
                360, 80, str, 14, fontName, 0x000000,
                15, 35, "left", "top", false
            );
            return text;
        }

    }
}
