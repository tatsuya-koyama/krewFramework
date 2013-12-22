package krewfw.builtin_actor {

    import starling.display.Image;
    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewSystemEventType;
    import krewfw.starling_utility.TextFactory;

    /**
     * テクスチャなどを使わずに、取り急ぎローディング画面を出すための Actor.
     * 以下のように書いておけば、一瞬で終わらないアセットのロード時に
     * Loading... という文字とロード進捗のバーを表示してくれる。
     *
     * <pre>
     *     public override function initLoadingView():void {
     *           setUpActor('l-back', new SimpleLoadingScreen(0x000000));
     *     }
     * <pre>
     */
    //------------------------------------------------------------
    public class SimpleLoadingScreen extends KrewActor {

        private var _loadingBarFg:ColorRect;
        private var _loadingBarBg:ColorRect;

        //------------------------------------------------------------
        public function SimpleLoadingScreen(bgColor:uint=0x000000, fontName:String="_sans") {
            addInitializer(function():void {
                var bg:ScreenCurtain = new ScreenCurtain(
                    bgColor, bgColor, bgColor, bgColor
                );
                addActor(bg);

                _loadingBarBg = _makeLoadingBar(0x555555, 0x555555, 2, 1.0);
                _loadingBarFg = _makeLoadingBar(0xffffff, 0xaaaaaa, 0, 0.0);
                addActor(_loadingBarBg);
                addActor(_loadingBarFg);

                addScheduledTask(0.3, function():void {
                    addText(_makeLoadingText(fontName), 80, 380);
                    listen(KrewSystemEventType.PROGRESS_ASSET_LOAD, _onLoadProgress);
                });

                listen(KrewSystemEventType.COMPLETE_ASSET_LOAD, _onLoadComplete);
            });
        }

        private function _onLoadProgress(args:Object):void {
            var loadRatio:Number = args.loadRatio;
            if (loadRatio - _loadingBarFg.scaleX > 0.1) {
                _loadingBarFg.react();
                _loadingBarFg.act().scaleToEaseOut(0.2, loadRatio, 1);
            }
        }

        private function _onLoadComplete(args:Object):void {
            passAway();
        }

        private function _makeLoadingText(fontName:String):TextField {
            var text:TextField = TextFactory.makeText(
                200, 50, "Loading...", 20, fontName, 0xffffff,
                0, 0, "right", "top", false
            );

            // blink animation
            var blinkLoop:Function = function():void {
                act().blink(text, 0.3, 0.3).doit(0, blinkLoop);
            };
            act().doit(0, blinkLoop);

            return text;
        }

        private function _makeLoadingBar(topColor:uint, bottomColor:uint,
                                         padding:Number, initScaleX:Number):ColorRect
        {
            var loadingBar:ColorRect = new ColorRect(
                280 + padding*2, 5 + padding*2, false,
                topColor, topColor, bottomColor, bottomColor
            );
            loadingBar.scaleX = initScaleX;
            loadingBar.x =  20 - padding;
            loadingBar.y = 420 - padding;

            loadingBar.alpha = 0;
            loadingBar.act().wait(0.1).alphaTo(0.2, 1);

            return loadingBar;
        }

    }
}
