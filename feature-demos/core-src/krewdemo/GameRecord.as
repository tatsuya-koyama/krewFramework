package krewdemo {

    import starling.errors.AbstractClassError;

    public class GameRecord {

        public function GameRecord() {
            // prohibit the instantiation of class
            throw new AbstractClassError();
        }

        public static var featureListScrollY:Number = 0;

    }
}
