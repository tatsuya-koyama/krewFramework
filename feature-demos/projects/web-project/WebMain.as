package {

    import flash.display.Sprite;
    import krewfw.KrewConfig;
    import krewfw.utility.KrewUtil;

    /**
     * Customize options or components for Flash publishing.
     */
    public class WebMain extends Sprite {

        public function WebMain() {
            KrewUtil.log("Kicked from WebMain");

            KrewConfig.ASSET_URL_SCHEME = "http://docs.tatsuya-koyama.com/assets/media/swf/krewdemo/";

            var main:Main = new Main(this);
        }
    }
}
