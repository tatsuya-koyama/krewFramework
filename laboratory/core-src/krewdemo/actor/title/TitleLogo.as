package krewdemo.actor.title {

    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class TitleLogo extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            var text:TextField = _makeTitleLogo();
            addText(text, 0, 80 + 8);

            alpha = 0;
            act().alphaTo(0.4, 1);
            act().moveEaseOut(0.5, 0, -8);
        }

        private function _makeTitleLogo():TextField {
            var text:TextField = TextFactory.makeText(
                480, 100, "krewFramework\nLaboratory", 40, "tk_courier", 0xcc9911,
                0, 0, "center", "top", false
            );
            text.blendMode = KrewBlendMode.MULTIPLY;
            return text;
        }
    }
}
