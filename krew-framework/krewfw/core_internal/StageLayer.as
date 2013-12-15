package krewfw.core_internal {

    import starling.animation.Juggler;
    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class StageLayer extends KrewActor {

        private var _juggler:Juggler = new Juggler();
        private var _timeScale:Number = 1;

        //------------------------------------------------------------
        public function get juggler():Juggler {
            return _juggler;
        }

        public function set timeScale(value:Number):void {
            _timeScale = value;
        }

        //------------------------------------------------------------
        public function StageLayer() {
            touchable = true;

            // Avoid rendering state change on Starling
            // (See http://wiki.starling-framework.org/manual/performance_optimization)
            alpha = 0.9999;
        }

        public override function dispose():void {
            _juggler.purge();
            super.dispose();
        }

        public override function onUpdate(passedTime:Number):void {
            var layerPassedTime:Number = passedTime * _timeScale;

            for (var i:int=0;  i < childActors.length;  ++i) {
                var actor:KrewActor = childActors[i];
                if (actor.isDead) {
                    childActors.splice(i, 1);  // remove dead actor from Array
                    removeChild(actor);
                    actor.dispose();
                    --i;
                    continue;
                }
                actor.update(layerPassedTime);
            }

            _juggler.advanceTime(layerPassedTime);
        }
    }
}
