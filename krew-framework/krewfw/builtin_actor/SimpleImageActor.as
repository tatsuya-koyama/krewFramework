package krewfw.builtin_actor {

    import starling.display.Image;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class SimpleImageActor extends KrewActor {

        //------------------------------------------------------------
        public function SimpleImageActor(imageName:String, width:Number, height:Number,
                                         x:Number=160, y:Number=240,
                                         anchorX:Number=0.5, anchorY:Number=0.5) {

            addInitializer(function():void {
                var image:Image = getImage(imageName);
                addImage(image, width, height, 0, 0, anchorX, anchorY);
            });

            this.x = x;
            this.y = y;
        }

    }
}
