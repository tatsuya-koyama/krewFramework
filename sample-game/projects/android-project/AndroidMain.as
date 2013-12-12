package {

    import flash.display.Sprite;
    import com.tatsuyakoyama.krewfw.KrewConfig;
    import com.tatsuyakoyama.krewfw.utility.KrewUtil;

    /**
     * Customize options or components for Android publishing.
     */
    public class AndroidMain extends Sprite {

        public function AndroidMain() {
            KrewUtil.log("Kicked from AndroidMain");

            KrewConfig.ASSET_URL_SCHEME = "app:/";

            var main:Main = new Main(this);
        }
    }
}
