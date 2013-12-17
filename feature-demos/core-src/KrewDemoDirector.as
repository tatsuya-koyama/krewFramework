package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import krewdemo.scene.TitleScene;

    //------------------------------------------------------------
    public class KrewDemoDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function KrewDemoDirector() {
            var firstScene:KrewScene = new TitleScene();
            startGame(firstScene);
        }

        protected override function getInitialGlobalAssets():Array {
            return [
                 'bmp_font/tk_courier.png'
                ,'bmp_font/tk_courier.fnt'
            ];
        }
    }
}
