package krewdemo.actor.common {

    import starling.display.Image;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;

    import krewdemo.GameConst;

    //------------------------------------------------------------
    public class ScreenFilter extends KrewActor {

        //------------------------------------------------------------
        public function ScreenFilter(alpha:Number=0.6, imageName:String="screen_filter") {
            addInitializer(function():void {
                var image:Image = getImage(imageName);
                image.blendMode = KrewBlendMode.MULTIPLY;
                image.alpha = alpha;

                addImage(
                    image,
                    GameConst.SCREEN_WIDTH,
                    GameConst.SCREEN_HEIGHT,
                    0, 0, 0.5, 0.5
                );

                x = GameConst.SCREEN_WIDTH  / 2;
                y = GameConst.SCREEN_HEIGHT / 2;
            });
        }

    }
}
