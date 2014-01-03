package krewdemo {

    import starling.errors.AbstractClassError;

    public class GameEvent {

        public function GameEvent() {
            // prohibit the instantiation of the class
            throw new AbstractClassError();
        }

        public static const EXIT_SCENE:String = 'exitScene';
        public static const BACK_SCENE:String = 'backScene';

        // expected args: {nextScene:KrewScene}
        public static const NEXT_SCENE:String = 'nextScene';

        public static const TRIGGER_JUMP:String = 'triggerJump';

    }
}
