package krewdemo.actor.world_test {

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class HugeWorldTester1 extends KrewActor {

        private var _colorMap:BitmapData;
        private var _densityMap:BitmapData;

        private var _numObject:int = 0;

        //------------------------------------------------------------
        public override function init():void {
            _colorMap = new BitmapData(512, 512, true, 0xff000000);
            _colorMap.perlinNoise(128, 128, 8, 12345678, true, true, 7, false, [new Point(150, 200)]);
            _setContrastFilter(_colorMap, 0.5);

            _densityMap = new BitmapData(512, 512, true, 0xff000000);
            _densityMap.perlinNoise(128, 128, 4, 87654321, true, true, 7, true, [new Point(50, 50)]);
            _setContrastFilter(_densityMap, 0.5);

            //_debugDisplay();

            _constructWorld(_colorMap, _densityMap);
            trace(" * number of object:", _numObject); ////////////// debug
        }

        protected override function onDispose():void {
            _colorMap.dispose();
            _densityMap.dispose();
        }

        public override function onUpdate(passedTime:Number):void {

        }

        private function _debugDisplay():void {
            var bitmap:Bitmap;
            var image:Image;

            bitmap = new Bitmap(_colorMap);
            image  = Image.fromBitmap(bitmap, false);
            addImage(image, 180, 180, 240 - 100, 160);

            bitmap = new Bitmap(_densityMap);
            image  = Image.fromBitmap(bitmap, false);
            addImage(image, 180, 180, 240 + 100, 160);
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

        private function _constructWorld(colorMap:BitmapData, densityMap:BitmapData):void {
            for (var px:int=256 - 50;  px < 256 + 50;  px += 4) {
                for (var py:int=256 - 50;  py < 256 + 50;  py += 4) {
                    _constructWorldGrid(
                        px, py,
                        colorMap  .getPixel(px, py),
                        densityMap.getPixel(px, py)
                    );
                }
            }
        }

        private function _constructWorldGrid(gridX:int, gridY:int,
                                             colorPixel:uint, densityPixel:uint):void
        {
            const WORLD_WIDTH :Number = 13000;
            const WORLD_HEIGHT:Number = 13000;
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
                var image:Image = _getImage();
                var randSize:Number = gridWidth * GRID_UNIT / 2;
                var imageX:Number = 240 + gridCenterX + krew.rand(-randSize, randSize);
                var imageY:Number = 160 + gridCenterY + krew.rand(-randSize, randSize);
                var size:Number   = krew.rand(40, 120);
                addImage(image, size, size, imageX, imageY);

                image.color    = colorPixel;
                image.alpha    = krew.rand(0.7, 1.0);
                image.rotation = krew.rand(0, 6.28);

                ++_numObject;
            }
        }

        private function _getImage():Image {
            var image:Image = getImage(krew.list.sample([
                "feather", "apple", "leaf_1", "leaf_2", "leaf_3", "rock"
            ]));
            return image;
        }

    }
}
