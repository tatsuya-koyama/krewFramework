package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TileMapHelper;

    //------------------------------------------------------------
    public class TileMapTester1 extends KrewActor {

        private var _tileMapDisplay:QuadBatch;

        private var _velocityX:Number = 0;
        private var _velocityY:Number = 0;

        //------------------------------------------------------------
        public override function init():void {
            _tileMapDisplay = _makeMapDisplay();
            _tileMapDisplay.scaleX = 1.0;
            _tileMapDisplay.scaleY = 1.0;
            addChild(_tileMapDisplay);

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        private function _makeMapDisplay():QuadBatch {
            var tileMapInfo:Object = getObject('testmap_001');
            var tileLayer:Object   = tileMapInfo.layers[0];
            var tileSet:Object     = tileMapInfo.tilesets[0];

            var quadBatch:QuadBatch  = new QuadBatch();
            var tilesTexture:Texture = getTexture(tileSet.name);

            for (var row:int = 0;  row < 54;  ++row) {
                for (var col:int = 0;  col < 70;  ++col) {

                    var image:Image = TileMapHelper.getTileImage(
                        tileMapInfo, tileLayer, tileSet, tilesTexture, col, row
                    );
                    if (!image) { continue; }

                    image.x = col * tileSet.tilewidth;
                    image.y = row * tileSet.tileheight;
                    image.smoothing = TextureSmoothing.NONE;

                    quadBatch.addImage(image);
                }
            }

            return quadBatch;
        }

        private function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX;
            _velocityY = args.velocityY;
        }

        public override function onUpdate(passedTime:Number):void {
            _tileMapDisplay.x += 300 * -_velocityX * passedTime;
            _tileMapDisplay.y += 300 * -_velocityY * passedTime;
        }

    }
}
