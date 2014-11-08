package krewdemo.actor.world_test {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.text.TextField;

    import krewfw.builtin_actor.world.KrewWorld;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.starling.TextFactory;

    import krewdemo.GameConst;

    //------------------------------------------------------------
    public class HugeWorldTester3 extends KrewActor {

        private var _colorMap:BitmapData;
        private var _densityMap:BitmapData;

        private var _numObject:int = 0;
        private var _textField:TextField;

        private var _world:KrewWorld;

        //------------------------------------------------------------
        public override function init():void {
            _colorMap   = _makeColorMap();
            _densityMap = _makeDensityMap();

            _initWorld();
        }

        private function _makeColorMap():BitmapData {
            var colorMap:BitmapData = new BitmapData(512, 512, true, 0xff000000);
            colorMap.perlinNoise(128, 128, 8, 12345678, true, true, 7, false, [new Point(150, 200)]);
            _setContrastFilter(colorMap, 0.5);
            return colorMap;
        }

        private function _makeDensityMap():BitmapData {
            var densityMap:BitmapData = new BitmapData(512, 512, true, 0xff000000);
            densityMap.perlinNoise(128, 128, 4, 87654321, true, true, 7, true, [new Point(50, 50)]);
            _setContrastFilter(densityMap, 0.5);
            return densityMap;
        }

        private function _initWorld():void {
            _world = new KrewWorld(
                GameConst.SCREEN_WIDTH  * 0.5,
                GameConst.SCREEN_HEIGHT * 0.5,
                GameConst.SCREEN_WIDTH  * 0.25,
                GameConst.SCREEN_HEIGHT * 0.25
            );
            addActor(_world);

            var cameraController:WorldCameraPrototype3 = new WorldCameraPrototype3(_world);
            createActor(cameraController);

            _world.addLayer("back",   "l-back",   20000, 20000, 0.5, 6, 0.2);
            _world.addLayer("ground", "l-ground", 20000, 20000, 1.0, 6, 0.2);
            _world.addLayer("front",  "l-front",  40000, 40000, 2.0, 6, 0.2);

            _constructWorld("back",   _colorMap, _densityMap, false, 2.0, _getImage);
            _constructWorld("ground", _colorMap, _densityMap, true,  1.0, _getOutlineImage);
            _constructWorld("front",  _colorMap, _densityMap, false, 1.0, _getImage);
        }

        protected override function onDispose():void {
            _colorMap.dispose();
            _densityMap.dispose();
        }

        public override function onUpdate(passedTime:Number):void {

        }

        private function _makeText(str:String="", fontName:String="tk_courier"):TextField {
            var text:TextField = TextFactory.makeText(
                360, 80, str, 14, fontName, 0x000000,
                15, 35, "left", "top", false
            );
            return text;
        }

        /**
         * @param level from -1.0 to 1.0
         */
        private function _setContrastFilter(bmp:BitmapData, level:Number):void {
            var s:Number = level + 1;
            var c:Number = 128 * (1 - s);

            var filter:ColorMatrixFilter = new ColorMatrixFilter([
                s, 0, 0, 0, c,  // red
                0, s, 0, 0, c,  // green
                0, 0, s, 0, c,  // blue
                0, 0, 0, 1, 0   // alpha
            ]);
            bmp.applyFilter(bmp, bmp.rect, new Point(), filter);
        }

        private function _constructWorld(worldLabel:String,
                                         colorMap:BitmapData, densityMap:BitmapData, actorMode:Boolean,
                                         baseScale:Number, imageFactory:Function):void
        {
            for (var px:int=256 - 92;  px < 256 + 74;  px += 4) {
                for (var py:int=256 - 88;  py < 256 + 78;  py += 4) {

                    _constructWorldGrid(
                        worldLabel, px, py,
                        colorMap  .getPixel(px, py),
                        densityMap.getPixel(px, py),
                        actorMode, baseScale, imageFactory
                    );
                }
            }
        }

        private function _constructWorldGrid(worldLabel:String, gridX:int, gridY:int,
                                             colorPixel:uint, densityPixel:uint, actorMode:Boolean,
                                             baseScale:Number, imageFactory:Function):void
        {
            const WORLD_WIDTH :Number = 23000 * baseScale;
            const WORLD_HEIGHT:Number = 23000 * baseScale;
            const GRID_SIZE:int       = 512;
            const GRID_UNIT:int       = 4;

            var gridWidth  :Number = WORLD_WIDTH  / GRID_SIZE;
            var gridHeight :Number = WORLD_HEIGHT / GRID_SIZE;
            var gridCenterX:Number = (gridX - GRID_SIZE / 2) * gridWidth;
            var gridCenterY:Number = (gridY - GRID_SIZE / 2) * gridHeight;

            var density:Number = krew.getBrightness(densityPixel);
            density = (density - 0.3) * 3.0;  // almost from 0 to 1
            var num:int = krew.randInt(1, density * 6);
            if (num <= 0) { num = 1; }

            while (num--) {
                var image:Image = imageFactory();
                var randSize:Number = gridWidth * GRID_UNIT / 2;
                var imageX:Number = 240 + gridCenterX + krew.rand(-randSize, randSize);
                var imageY:Number = 160 + gridCenterY + krew.rand(-randSize, randSize);
                var size:Number   = krew.rand(40, 180);
                if (krew.rand(100) < 7) { size = krew.rand(280, 460); }
                size *= baseScale;

                if (actorMode) {
                    var actor:BGObjectActor = new BGObjectActor();
                    actor.addImage(image, size, size, 0, 0);
                    actor.x = imageX;
                    actor.y = imageY;
                    _world.putActor(worldLabel, actor, size, size);
                }
                else {
                    image.x = imageX;
                    image.y = imageY;
                    image.width  = size;
                    image.height = size;
                    _world.putDisplayObj(worldLabel, image, size, size);
                }

                image.color    = colorPixel;
                image.rotation = krew.rand(0, 6.28);

                ++_numObject;
            }
        }

        private function _getImage():Image {
            var image:Image = getImage(krew.list.sample([
                "feather", "apple", "leaf_1", "leaf_2", "leaf_3", "rock"
            ]));
            image.blendMode = KrewBlendMode.MULTIPLY;
            image.alpha     = krew.rand(0.7, 1.0);
            return image;
        }

        private function _getOutlineImage():Image {
            var image:Image = getImage(krew.list.sample([
                "outline_feather", "outline_apple",
                "outline_leaf_1", "outline_leaf_2", "outline_leaf_3",
                "outline_rock"
            ]));
            image.blendMode = KrewBlendMode.NORMAL;
            image.alpha     = 1.0;
            return image;
        }

    }
}
