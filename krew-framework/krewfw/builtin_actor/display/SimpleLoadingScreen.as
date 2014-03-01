package krewfw.builtin_actor.display {

    import starling.text.TextField;

    import krewfw.KrewConfig;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewSystemEventType;
    import krewfw.utils.starling.TextFactory;

    /**
     * テクスチャなどを使わずに、取り急ぎローディング画面を出すための Actor.
     * 以下のように書いておけば、一瞬で終わらないアセットのロード時に
     * Loading... という文字とロード進捗のバーを表示してくれる。
     *
     * <pre>
     *     public override function initLoadingView():void {
     *           setUpActor('l-back', new SimpleLoadingScreen(0x000000));
     *     }
     * </pre>
     */
    //------------------------------------------------------------
    public class SimpleLoadingScreen extends KrewActor {

        private var _loadingBarFg:ColorRect;
        private var _loadingBarBg:ColorRect;

        //------------------------------------------------------------
        /**
         * デフォルトではバーの動きは Scene-Scope のアセット読み込みにのみ反応する。
         * Global-Scope に反応させたい場合は globalAssetMode に true を渡してほしい
         * （両方合わせて伸びきるようにするのは、読み込むファイルのサイズが分からないから難しいね）
         */
        public function SimpleLoadingScreen(bgColor:uint=0x000000, globalAssetMode:Boolean=false,
                                            fontName:String="_sans")
        {
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
                    addText(
                        _makeLoadingText(fontName),
                        0, KrewConfig.SCREEN_HEIGHT / 2 - 25
                    );
                });

                if (globalAssetMode) {
                    listen(KrewSystemEventType.PROGRESS_GLOBAL_ASSET_LOAD, _onLoadProgress);
                    listen(KrewSystemEventType.COMPLETE_GLOBAL_ASSET_LOAD, _onLoadComplete);
                } else {
                    listen(KrewSystemEventType.PROGRESS_ASSET_LOAD, _onLoadProgress);
                    listen(KrewSystemEventType.COMPLETE_ASSET_LOAD, _onLoadComplete);
                }
            });
        }

        private function _onLoadProgress(args:Object):void {
            var loadRatio:Number = args.loadRatio;
            _loadingBarFg.scaleX = loadRatio;
        }

        private function _onLoadComplete(args:Object):void {
            passAway();
        }

        private function _makeLoadingText(fontName:String):TextField {
            var text:TextField = TextFactory.makeText(
                KrewConfig.SCREEN_WIDTH, 50, "Loading...", 20, fontName, 0xcccccc,
                0, 0, "center", "top", false
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
            var barWidth :Number = 280 + (padding * 2);
            var barHeight:Number =   5 + (padding * 2);

            var loadingBar:ColorRect = new ColorRect(
                barWidth, barHeight, false,
                topColor, topColor, bottomColor, bottomColor
            );
            loadingBar.scaleX = initScaleX;
            loadingBar.x = (KrewConfig.SCREEN_WIDTH - barWidth) / 2;
            loadingBar.y = (KrewConfig.SCREEN_HEIGHT / 2 + 20) - padding;

            loadingBar.alpha = 0;
            loadingBar.act().wait(0.1).alphaTo(0.2, 1);

            return loadingBar;
        }

    }
}
