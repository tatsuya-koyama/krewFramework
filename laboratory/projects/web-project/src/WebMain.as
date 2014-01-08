package {

    import flash.display.Sprite;
    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    /**
     * Customize options or components for Flash publishing.
     */
    public class WebMain extends Sprite {

        public function WebMain() {
            krew.log("Kicked from WebMain");

            KrewConfig.ASSET_URL_SCHEME = "http://docs.tatsuya-koyama.com/assets/media/swf/krewdemo/";

            var main:Main = new Main(this);
        }
    }
}
