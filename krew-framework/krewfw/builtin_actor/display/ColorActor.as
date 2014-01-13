package krewfw.builtin_actor.display {

    import krewfw.core.KrewActor;

    /**
     * Fade color represented by interger smoothly.
     */
    //------------------------------------------------------------
    public class ColorActor extends KrewActor {

        public var red  :int;
        public var green:int;
        public var blue :int;

        //------------------------------------------------------------
        public function get colorInt():int {
            return krew.rgb2int(red, green, blue);
        }

        //------------------------------------------------------------
        public function ColorActor(color:int) {
            red   = krew.getRed  (color);
            green = krew.getGreen(color);
            blue  = krew.getBlue (color);
        }

        public function fadeTo(color:int, fadeTime:Number=1.0):void {
            enchant(fadeTime).animate('red'  , krew.getRed  (color))
            enchant(fadeTime).animate('green', krew.getGreen(color))
            enchant(fadeTime).animate('blue' , krew.getBlue (color))
        }
    }
}
