package krewfw {

    import starling.utils.AssetManager;

    /**
     * Please customize these static values for your game
     * before the calling KrewGameDirector.startGame().
     */
    public class KrewConfig {

        /**
         * AIR の場合はこれを true にする。Flash なら false のままにすること。
         * true にすると、krewFramework が AIR でのみ提供されている機能を
         * 利用するようになる。（KrewSoundPlayer で端末の Mute 機能を使うなど）
         *
         * これを true にすると mxmlc による Flash 向けのビルドが失敗するので注意。
         */
        public static var IS_AIR:Boolean = false;

        /** Virtual screen size */
        public static var SCREEN_WIDTH :int = 480;

        /** Virtual screen size */
        public static var SCREEN_HEIGHT:int = 320;

        /**
         * FPS がどこまで落ちるのを許すか。
         * これ以上の遅れは単純な処理落ちとして扱う
         */
        public static var ALLOW_DELAY_FPS:int = 15;

        //------------------------------------------------------------
        // Asset Manager
        //------------------------------------------------------------

        /**
         * ビルド対象のプラットフォームに応じて、ファイルアクセスのベースパスとなる
         * スキーマを任意に指定してほしい.
         * このスキーマは krewfw.core_internal.KrewResourceManager でのパス解決に使用される。
         *
         * <ul>
         *   <li>ローカルでテストしたい場合は空文字列 "" でよい。
         *       （swf と同じ階層にアセットディレクトリのリンクなど置いておくことを想定）
         *   </li>
         *   <li>iOS, Android アプリの場合は "app:/" を指定する</li>
         *   <li>アプリから保存したデータ領域にアクセスするには "app-storage:/" を指定する</li>
         *   <li>Web 上で Flash として公開したい場合は "http://..." のように
         *       アセットが置かれている URL を指定すればよい
         *   </li>
         * </ul>
         */
        public static var ASSET_URL_SCHEME:String = "";

        public static var ASSET_BASE_PATH:String = "asset/";

        /**
         * krewFramework はアセット読み込みに starling.utils.AssetManager を用いる。
         * AssetManager のサブクラスであれば、ここを書き換えることによって任意のクラスを
         * 代わりに利用することができる。 例えばリソースの登録名などが気に入らない場合は
         * AssetManager.getName() を override したクラスを用意し、ここに指定すればよい。
         */
        public static var ASSET_MANAGER_CLASS:Class = AssetManager;


        //------------------------------------------------------------
        // Debug and Profiling
        //------------------------------------------------------------

        /**
         * KrewFramework のログ (krew.fwlog) のレベル.
         * <ul>
         *   <li>0 にすると吐かない</li>
         *   <li>1 で普通に trace</li>
         *   <li>2 だと吐いたクラス名やソースの行数も付与する</li>
         * </ul>
         *
         * [ToDo] 現状 2 にしておくと実機で動かしたときにうまく動かなかった気がする…
         */
        public static var FW_LOG_VERBOSE:int = 1;

        /**
         * ゲーム側で利用するログ (KrewUtil.log) のレベル.
         * 数字の意味は FW_LOG_VERBOSE と同様
         */
        public static var GAME_LOG_VERBOSE:int = 1;

        /** true にすると１秒に１回各 layer の Actor 数をログに吐く */
        public static var WATCH_NUM_ACTOR:Boolean = false;

        /** true にすると starling.utils.AssetMamager のログを吐く */
        public static var ASSET_MANAGER_VERBOSE:Boolean = false;
    }
}
