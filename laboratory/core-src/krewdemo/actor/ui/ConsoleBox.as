package krewdemo.actor.ui {

    import flash.text.TextFormat;

    import starling.display.Image;

    import feathers.controls.ScrollBar;
    import feathers.controls.ScrollText;

    import krewfw.core.KrewActor;

    import krewdemo.actor.ui.TextButton;

    //------------------------------------------------------------
    public class ConsoleBox extends KrewActor {

        private var _console:ScrollText;

        //------------------------------------------------------------
        public function ConsoleBox(left:Number, top:Number, width:Number, height:Number,
                                   padding:Number=5,
                                   fontSize:Number=12, fontName:String="Courier",
                                   fontColor:uint=0xe0e0e0, isHTML:Boolean=true)
        {
            touchable = true;

            addInitializer(function():void {
                _addBgRect(left, top, width, height);

                _console = new ScrollText();
                addChild(_console);

                _console.isHTML = isHTML;
                _console.textFormat = new TextFormat(fontName, fontSize, fontColor);

                _console.x = left + padding;
                _console.y = top  + padding;
                _console.width  = width  - (padding * 2);
                _console.height = height - (padding * 2);

                _console.verticalScrollBarFactory = _verticalScrollBarFactory;
            });
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        public function get text():String { return _console.text; }
        public function set text(text:String):void { _console.text = text; }

        // 末尾に追加
        public function appendText(text:String):void {
            _console.text += text;
        }

        // 先頭に追加
        public function unshiftText(text:String):void {
            _console.text = text + _console.text;
        }

        public function clear():void {
            _console.text = null;
        }

        public function toBottom():void {
            // text をセットした frame では最大高さが更新されないようなので次 frame で
            delayedFrame(function():void {
                _console.verticalScrollPosition = _console.maxVerticalScrollPosition;
            });
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _addBgRect(left:Number, top:Number, width:Number, height:Number):void {
            var image:Image = getImage("white");
            image.color = 0x000000;
            image.alpha = 0.5;
            addImage(image, width, height, left, top, 0, 0);
        }

        private function _verticalScrollBarFactory():ScrollBar {
            var scrollBar:ScrollBar = new ScrollBar();
            scrollBar.direction = ScrollBar.DIRECTION_HORIZONTAL;

            var image:Image = getImage("white");
            image.color = 0x888888;
            scrollBar.thumbProperties.defaultSkin = image;
            scrollBar.thumbProperties.width = 5;

            scrollBar.trackLayoutMode = ScrollBar.TRACK_LAYOUT_MODE_SINGLE;
            return scrollBar;
        }

    }
}
