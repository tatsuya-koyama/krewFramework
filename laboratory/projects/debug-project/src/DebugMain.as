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

            KrewConfig.ASSET_URL_SCHEME = "";

            var main:Main = new Main(this);
        }
    }
}
