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

        //------------------------------------------------------------
        public static function registerExtendedTransitions():void {
            Transitions.register(EASE_IN_QUAD,  _easeInQuad);
            Transitions.register(EASE_OUT_QUAD, _easeOutQuad);
        }

        private static function _easeInQuad(ratio:Number):Number {
            return ratio * ratio;
        }

        private static function _easeOutQuad(ratio:Number):Number {
            var invRatio:Number = ratio - 1.0;
            return (-invRatio * invRatio) + 1;
        }

    }
}
