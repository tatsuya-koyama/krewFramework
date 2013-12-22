package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.Sprite;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TextFactory;

    //------------------------------------------------------------
    public class SpriteTileTester extends KrewActor {

        private var _offsetX:Number = 0;
        private var _spriteBg :Sprite;
        private var _spriteFg1:Sprite;
        private var _spriteFg2:Sprite;

        //------------------------------------------------------------
        public override function init():void {
            _spriteBg  = new Sprite();
            _spriteFg1 = new Sprite();
            _spriteFg2 = new Sprite();

            _initSprites(_spriteBg ,  0,  0, 16, 20, 34, 16, 0x555555);
            _initSprites(_spriteFg1,  0,  0, 32, 10, 19, 16, 0xffffff);
            _initSprites(_spriteFg2, 16, 16, 32, 10, 19, 16, 0x999999);

            addChild(_spriteBg);
            addChild(_spriteFg1);
            addChild(_spriteFg2);
        }

        private function _initSprites(sprite:Sprite, offsetX:Number, offsetY:Number,
                                      cellSize:Number=32, maxRow:uint=15, maxCol:uint=12,
                                      imageSize:Number=32, color:uint=0xffffff):void
        {
            var cellSize:Number = cellSize;
            for (var row:int = 0;  row < maxRow;  ++row) {
                for (var col:int = 0;  col < maxCol;  ++col) {
                    var imageName:String = ((row + col) % 2 == 0) ? 'invader' : 'pyramid';
                    var image:Image = getImage(imageName);
                    image.x = (col * cellSize) + offsetX;
                    image.y = (row * cellSize) + offsetY;
                    image.width = image.height = imageSize;
                    image.color = color;
                    sprite.addChild(image);
                }
            }
        }

        public override function onUpdate(passedTime:Number):void {
            _offsetX -= passedTime * 128;
            if (_offsetX < -128) { _offsetX += 128; }

            _spriteBg .x = _offsetX / 4;
            _spriteFg1.x = _offsetX;
            _spriteFg2.x = _offsetX / 2;
        }

    }
}
