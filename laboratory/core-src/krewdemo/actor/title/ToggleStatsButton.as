package krewdemo.actor.title {

    import starling.events.Event;

    import krewdemo.GameStatic;
    import krewdemo.actor.ui.TextButton;

    //------------------------------------------------------------
    public class ToggleStatsButton extends TextButton {

        private static const ORIGINAL_STATS_WIDTH:Number = 70;

        private static var _showStats:Boolean = false;

        //------------------------------------------------------------
        public function ToggleStatsButton() {
            super(80, 295, "Toggle Stats", 16, 10, 5);
            setOnPress(_onPress);
        }

        private function _onPress(event:Event):void {
            GameStatic.statsView.toggleStatsVisible();
        }

    }
}
