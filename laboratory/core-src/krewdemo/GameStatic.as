package krewdemo {

    import krewfw.extension.dragonbones.DBoneFactories;

    public class GameStatic {

        public static var boneFactories:DBoneFactories;

        public static function init():void {
            boneFactories = new DBoneFactories();
        }

    }
}
