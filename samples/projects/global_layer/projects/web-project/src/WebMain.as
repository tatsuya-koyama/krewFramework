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

            KrewConfig.IS_AIR = false;
            KrewConfig.ASSET_URL_SCHEME = "http://uri/to/assets/";

            var main:Main = new Main(this);
        }
    }
}
