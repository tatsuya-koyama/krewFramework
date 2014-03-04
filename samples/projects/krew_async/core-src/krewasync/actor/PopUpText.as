package krewasync.actor {

    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class PopUpText extends KrewActor {

        //------------------------------------------------------------
        public function PopUpText(caption:String, color:uint, posX:Number, posY:Number,
                                  waitTime:Number=0)
        {
            addInitializer(function():void {
                var text:TextField = _makeLogo(caption, color);
                addText(text, -100, -30);
                x = posX;
                y = posY;

                act().moveEaseOut(0.2, 0, -25).move(0.6, 0, 25, "easeOutBounce")
                    .wait(waitTime).alphaTo(0.5, 0).kill();
            });
        }

        private function _makeLogo(caption:String, color:uint):TextField {
            var text:TextField = TextFactory.makeText(
                200, 60, caption, 12, "tk_cooper", color,
                0, 0, "center", "center", false
            );
            return text;
        }
    }
}
