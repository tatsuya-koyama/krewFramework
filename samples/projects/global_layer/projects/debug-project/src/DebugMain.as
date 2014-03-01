package {

    import flash.display.Sprite;
    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    /**
     * Customize options or components for local debug.
     */
    public class DebugMain extends Sprite {

        public function DebugMain() {
            krew.log("Kicked from DebugMain");

            KrewConfig.IS_AIR = false;
            KrewConfig.ASSET_URL_SCHEME = "";
            KrewConfig.ASSET_URL_SCHEME = "http://docs.tatsuya-koyama.com/assets/media/swf/krewsample/";

            var main:Main = new Main(this);
        }
    }
}
