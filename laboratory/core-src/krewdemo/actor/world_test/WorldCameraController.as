package krewdemo.actor.world_test {

    import flash.geom.Rectangle;

    import starling.display.Image;
    import starling.text.TextField;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.starling.TextFactory;

    import krewdemo.GameConst;
    import krewdemo.GameEvent;

    //------------------------------------------------------------
    public class WorldCameraController extends KrewActor {

        private var _world:KrewWorld;

        private var _focusX:Number = 0;
        private var _focusY:Number = 0;
        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        private var _zoomScale:Number = 1.0;
        private var _targetZoomScale:Number = 1.0;

        private var _textField:TextField;
        private var _screenRect:KrewActor;

        //------------------------------------------------------------
        public function WorldCameraController(world:KrewWorld) {
            displayable = false;
            _world = world;
        }

        public override function init():void {
            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
            listen(GameEvent.TRIGGER_ZOOM, _onZoom);
            listen(GameEvent.TOGGLE_DEBUG_VIEW, _onToggleDebugView);

            _targetZoomScale = 0.5;

            // debug info
            var actor:KrewActor = new KrewActor();
            _textField = _makeText("x, y: ");
            actor.addText(_textField, 58, 5);
            createActor(actor, 'l-front');

            _screenRect = _addScreenSizeRect();
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
                case 0.10: _targetZoomScale = 0.02; break;
                default  : _targetZoomScale = 1.00; break;
            }
        }

        private function _onToggleDebugView(args:Object):void {
            if (args.debugViewMode) {
                _screenRect.visible = true;
                _world.updateScreenSize(
                    GameConst.SCREEN_WIDTH  * 0.5,
                    GameConst.SCREEN_HEIGHT * 0.5,
                    GameConst.SCREEN_WIDTH  * 0.25,
                    GameConst.SCREEN_HEIGHT * 0.25
                );
                _world.treeRoot.setDebugRectVisible(true);
            }
            else {
                _screenRect.visible = false;
                _world.updateScreenSize(
                    GameConst.SCREEN_WIDTH  * 1.0,
                    GameConst.SCREEN_HEIGHT * 1.0,
                    0, 0
                );
                _world.treeRoot.setDebugRectVisible(false);
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _focusX += (300 / _zoomScale * _velocityX) * passedTime;
            _focusY += (300 / _zoomScale * _velocityY) * passedTime;

            _zoomScale += (_targetZoomScale - _zoomScale) * 2.0 * passedTime;

            _world.setFocusPos(_focusX, _focusY);
            _world.setZoomScale(_zoomScale);
            _world.updateViewport();

            _updateDebugPrint();
        }

        private function _updateDebugPrint():void {
            var viewport:Rectangle = _world.viewport;
            _textField.text = "x, y: " + Math.round(_focusX)
                            + ", "     + Math.round(_focusY) + "\n"
                            + "zoom: " + Math.round(_zoomScale * 100) / 100 + "\n"
                            + "viewport: " + Math.round(viewport.x) + ", "
                                           + Math.round(viewport.y) + " to "
                                           + Math.round(viewport.x + viewport.width) + ", "
                                           + Math.round(viewport.y + viewport.height) + "\n"
                            + "active actor: " + QuadTreeSprite.stat_countActorUpdate;
        }

        private function _makeText(str:String="", fontName:String="tk_courier"):TextField {
            var text:TextField = TextFactory.makeText(
                360, 80, str, 14, fontName, 0x558800,
                15, 35, "left", "top", false
            );
            text.blendMode = KrewBlendMode.MULTIPLY;
            return text;
        }

        private function _addScreenSizeRect():KrewActor {
            var actor:KrewActor = new KrewActor();

            var image:Image = getImage("rect");
            image.color = 0x000000;
            image.alpha = 0.4;
            actor.addImage(image, 480 * 0.5, 320 * 0.5);
            actor.x = 240;
            actor.y = 160;

            createActor(actor, 'l-ui');
            return actor;
        }

    }
}
