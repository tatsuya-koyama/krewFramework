package {

    import krewfw.core.KrewScene;
    import krewfw.core.KrewGameDirector;

    import krewdemo.scene.*;

    //------------------------------------------------------------
    public class KrewDemoDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function KrewDemoDirector() {
            var firstScene:KrewScene = new TitleScene();
            //var firstScene:KrewScene = new PlatformerTestScene1();
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
