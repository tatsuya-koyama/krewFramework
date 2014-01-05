package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TextFactory;

    //------------------------------------------------------------
    public class QuadBatchTester3 extends KrewActor {

        private var _offsetX:Number = 0;
        private var _quadBatchBg :QuadBatch;
        private var _quadBatchFg1:QuadBatch;
        private var _quadBatchFg2:QuadBatch;

        //------------------------------------------------------------
        public override function init():void {
            _quadBatchBg  = new QuadBatch();
            _quadBatchFg1 = new QuadBatch();
            _quadBatchFg2 = new QuadBatch();

            _setQuadBatch(_quadBatchBg ,  0,  0, 16, 20, 34, 16, 0x555555);
            _setQuadBatch(_quadBatchFg1,  0,  0, 32, 10, 19, 16, 0xffffff);
            _setQuadBatch(_quadBatchFg2, 16, 16, 32, 10, 19, 16, 0x999999);

            addChild(_quadBatchBg);
            addChild(_quadBatchFg1);
            addChild(_quadBatchFg2);
        }

        private function _setQuadBatch(quadBatch:QuadBatch, offsetX:Number, offsetY:Number,
                                       cellSize:Number=32, maxRow:uint=15, maxCol:uint=12,
                                       imageSize:Number=32, color:uint=0xffffff):void
        {
            quadBatch.reset();

            var cellSize:Number = cellSize;
            for (var row:int = 0;  row < maxRow;  ++row) {
                for (var col:int = 0;  col < maxCol;  ++col) {
                    var imageName:String = ((row + col) % 2 == 0) ? 'invader' : 'pyramid';
                    var image:Image = getImage(imageName);
                    image.x = (col * cellSize) + offsetX;
                    image.y = (row * cellSize) + offsetY;
                    image.width = image.height = imageSize;
                    image.color = color;
                    quadBatch.addImage(image);
                }
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _offsetX -= passedTime * 128;
            if (_offsetX < -128) { _offsetX += 128; }

            _quadBatchBg .x = _offsetX / 4;
            _quadBatchFg1.x = _offsetX;
            _quadBatchFg2.x = _offsetX / 2;
        }

    }
}
