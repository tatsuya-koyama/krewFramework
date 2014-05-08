package krewfw.core {

    import starling.animation.Transitions;

    /**
     * Expand tween transition functions of Starling.
     */
    //------------------------------------------------------------
    public class KrewTransition {

        // Already exists in starling
        public static const EASE_IN_QUAD :String = "krew.easeInQuad";  // quadratic
        public static const EASE_OUT_QUAD:String = "krew.easeOutQuad";
        public static const SWING        :String = "krew.swing";

        //------------------------------------------------------------
        public static function registerExtendedTransitions():void {
            Transitions.register(EASE_IN_QUAD,  _easeInQuad);
            Transitions.register(EASE_OUT_QUAD, _easeOutQuad);
            Transitions.register(SWING,         _swing);
        }

        private static function _easeInQuad(ratio:Number):Number {
            return ratio * ratio;
        }

        private static function _easeOutQuad(ratio:Number):Number {
            var invRatio:Number = ratio - 1.0;
            return (-invRatio * invRatio) + 1;
        }

        private static function _swing(ratio:Number):Number {
            var swing:Number = 1 + (Math.sin(ratio * 8 * Math.PI) * (1 - ratio));

            if (ratio < 0.3) {
                var initInvRatio:Number = (ratio / 0.3) - 1.0;
                var initEaseOut:Number  = (-initInvRatio * initInvRatio) + 1;
                swing *= initEaseOut;
            }

            return swing;
        }

    }
}
