package global_layer.actor {

    import starling.text.TextField;

    import krewfw.builtin_actor.display.ColorRect;
    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class GlobalView extends KrewActor {

        //------------------------------------------------------------
        public function GlobalView(caption:String="LOGO", color:uint=0xffcc55):void {
            addInitializer(function():void {

                //--- bg quad
                var rect:ColorRect = new ColorRect(480, 100, false, 0xffffff);
                rect.y = 320 - 30;
                rect.alpha = 0.4;
                addActor(rect);

                var moveRect:Function = function():void {
                    rect.act()
                        .moveEaseOut(4.0, 0, -30)
                        .moveEaseOut(4.0, 0,  30)
                        .justdoit(0, moveRect);
                };
                rect.act().justdoit(0, moveRect);


                //--- text
                var textActor:KrewActor = new KrewActor();
                addActor(textActor);

                var text:TextField = _makeLogo(caption, color);
                textActor.addText(text, -20, 280 + 50);

                var moveText:Function = function():void {
                    textActor.act()
                        .moveEaseOut(3.0,  80, 0)
                        .moveEaseOut(3.0, -80, 0)
                        .justdoit(0, moveText);
                };
                textActor.act().moveEaseOut(3.0, 0, -50).justdoit(0, moveText);
            });
        }

        private function _makeLogo(caption:String, color:uint):TextField {
            var text:TextField = TextFactory.makeText(
                480, 100, caption, 25, "tk_cooper", color,
                0, 0, "center", "top", false
            );
            return text;
        }
    }
}
