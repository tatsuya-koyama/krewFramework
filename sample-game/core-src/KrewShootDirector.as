package {

    import com.tatsuyakoyama.krewfw.core.KrewScene;
    import com.tatsuyakoyama.krewfw.core.KrewGameDirector;

    import krewshoot.scene.TitleScene;

    //------------------------------------------------------------
    public class KrewShootDirector extends KrewGameDirector {

        //------------------------------------------------------------
        public function KrewShootDirector() {
            var firstScene:KrewScene = new TitleScene();
            startGame(firstScene);
        }

        protected override function getInitialGlobalAssets():Array {
            return [
                 'bmp_font/tk_cooper.png'
                ,'bmp_font/tk_cooper.fnt'
            ];
        }
    }
}
