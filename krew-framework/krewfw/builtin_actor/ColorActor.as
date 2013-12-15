package krewfw.builtin_actor {

    import krewfw.core.KrewActor;
    import krewfw.utility.KrewUtil;

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
            return KrewUtil.rgb2int(red, green, blue);
        }

        //------------------------------------------------------------
        public function ColorActor(color:int) {
            red   = KrewUtil.getRed  (color);
            green = KrewUtil.getGreen(color);
            blue  = KrewUtil.getBlue (color);
        }

        public function fadeTo(color:int, fadeTime:Number=1.0):void {
            enchant(fadeTime).animate('red'  , KrewUtil.getRed  (color))
            enchant(fadeTime).animate('green', KrewUtil.getGreen(color))
            enchant(fadeTime).animate('blue' , KrewUtil.getBlue (color))
        }
    }
}
