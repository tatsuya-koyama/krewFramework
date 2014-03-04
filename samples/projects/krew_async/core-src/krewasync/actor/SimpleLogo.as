package krewasync.actor {

    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class SimpleLogo extends KrewActor {

        //------------------------------------------------------------
        public function SimpleLogo(caption:String="LOGO", color:uint=0xffcc55):void {
            addInitializer(function():void {
                var text:TextField = _makeLogo(caption, color);
                addText(text, 0, 35 + 9);

                alpha = 0;
                act().alphaTo(0.4, 1);
                act().moveEaseOut(0.5, 0, -9);
            });
        }

        private function _makeLogo(caption:String, color:uint):TextField {
            var text:TextField = TextFactory.makeText(
                480, 100, caption, 30, "tk_cooper", color,
                0, 0, "center", "top", false
            );
            return text;
        }
    }
}
