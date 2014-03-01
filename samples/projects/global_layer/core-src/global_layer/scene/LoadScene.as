package global_layer.scene {

    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;

    //------------------------------------------------------------
    public class LoadScene extends KrewScene {

        //------------------------------------------------------------
        public override function getLayerList():Array {
            return ['l-back'];
        }

        public override function getAdditionalGlobalAssets():Array {
            return [
                 'bmp_font/tk_cooper.png'
                ,'bmp_font/tk_cooper.fnt'
                ,"image/atlas_game.png"
                ,"image/atlas_game.xml"
            ];
        }

        public override function initLoadingView():void {
            setUpActor('l-back', new SimpleLoadingScreen(0x333333, true));
        }

        public override function initAfterLoad():void {
            blackOut(0.2);
            delayed(0.2, exit);
        }

        public override function getDefaultNextScene():KrewScene {
            return new BootScene();
        }
    }
}
