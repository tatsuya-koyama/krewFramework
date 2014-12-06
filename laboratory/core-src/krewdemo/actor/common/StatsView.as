package krewdemo.actor.common {

    import flash.display.Stage;

    import starling.core.Starling;
    import starling.events.Event;

    import krewfw.NativeStageAccessor;

    import krewdemo.GameStatic;
    import krewdemo.actor.ui.TextButton;

    import net.hires.debug.Stats;

    //------------------------------------------------------------
    public class StatsView {

        private static const ORIGINAL_STATS_WIDTH:Number = 70;

        private var _stats:Stats;
        private var _showStats:Boolean = false;

        //------------------------------------------------------------
        public function StatsView() {
            _stats = new Stats();
            _initStatsView();
        }

        public function toggleStatsVisible():void {
            _showStats = !_showStats;
            _stats.visible = _showStats;
        }

        private function _initStatsView():void {
            _stats.alpha = 0.8;
            _stats.scaleX = _stats.scaleY = _getStatsScale();

            var stage:Stage = NativeStageAccessor.stage;
            _stats.x = stage.stageWidth - (ORIGINAL_STATS_WIDTH * _stats.scaleX);

            stage.addChild(_stats);
            _stats.visible = _showStats;
        }

        private function _getStatsScale():Number {
            var stage:Stage = NativeStageAccessor.stage;
            var targetWidth:Number = stage.stageWidth * 0.15;
            return targetWidth / ORIGINAL_STATS_WIDTH;
        }

    }
}
