package {

    import flash.display.Sprite;
    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    /**
     * Customize options or components for Android publishing.
     */
    public class AndroidMain extends Sprite {

        public function AndroidMain() {
            krew.log("Kicked from AndroidMain");

            KrewConfig.IS_AIR = true;
            KrewConfig.ASSET_URL_SCHEME = "app:/";

            var main:Main = new Main(this);
        }
    }
}
