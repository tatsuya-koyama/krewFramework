package {

    import flash.display.Sprite;
    import krewfw.KrewConfig;
    import krewfw.utility.krew;

    /**
     * Customize options or components for Flash publishing.
     */
    public class WebMain extends Sprite {

        public function WebMain() {
            krew.log("Kicked from WebMain");

            KrewConfig.ASSET_URL_SCHEME = "";

            var main:Main = new Main(this);
        }
    }
}
