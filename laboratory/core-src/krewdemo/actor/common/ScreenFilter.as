package krewdemo.actor.common {

    import starling.display.Image;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;

    import krewdemo.GameConst;

    //------------------------------------------------------------
    public class ScreenFilter extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            var image:Image = getImage('screen_filter');
            image.blendMode = KrewBlendMode.SUB;
            image.alpha = 0.4;
            addImage(
                image,
                GameConst.SCREEN_WIDTH,
                GameConst.SCREEN_HEIGHT,
                0, 0, 0.5, 0.5
            );
            x = GameConst.SCREEN_WIDTH  / 2;
            y = GameConst.SCREEN_HEIGHT / 2;
        }

    }
}
