package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TextFactory;

    //------------------------------------------------------------
    public class QuadBatchTester1 extends KrewActor {

        private var _offsetX:Number = 0;
        private var _quadBatchBg:QuadBatch;
        private var _quadBatchFg:QuadBatch;

        //------------------------------------------------------------
        public override function init():void {
            _quadBatchBg = new QuadBatch();
            _quadBatchFg = new QuadBatch();

            onUpdate(0);

            addChild(_quadBatchBg);
            addChild(_quadBatchFg);
        }

        private function _setQuadBatch(quadBatch:QuadBatch, offsetX:Number,
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
                    image.y =  row * cellSize;
                    image.width = image.height = imageSize;
                    image.color = color;
                    quadBatch.addImage(image);
                }
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _offsetX -= passedTime * 128;
            if (_offsetX < -128) { _offsetX += 128; }

            _setQuadBatch(_quadBatchBg, _offsetX / 2, 32, 10, 17, 32, 0x888888);
            _setQuadBatch(_quadBatchFg, _offsetX,     32, 10, 19, 16, 0xffffff);
        }

    }
}
