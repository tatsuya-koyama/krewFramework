package krewdemo {

    import krewfw.extension.dragonbones.DBoneFactories;

    import krewdemo.actor.common.StatsView;

    public class GameStatic {

        public static var boneFactories:DBoneFactories;
        public static var statsView:StatsView;

        public static function init():void {
            boneFactories = new DBoneFactories();
            statsView = new StatsView();
        }

    }
}
