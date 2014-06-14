package krewdemo.actor.title {

    import krewfw.builtin_actor.display.SimpleImageActor;

    //------------------------------------------------------------
    public class Tile extends SimpleImageActor {

        public var homeX:Number;
        public var homeY:Number;

        //------------------------------------------------------------
        public function Tile(imageName:String, width:Number, height:Number,
                             x:Number=160, y:Number=240, anchorX:Number=0.5, anchorY:Number=0.5)
        {
            super(imageName, width, height, x, y, anchorX, anchorY);
        }

        public override function init():void {
            homeX = x;
            homeY = y;
        }

    }
}
