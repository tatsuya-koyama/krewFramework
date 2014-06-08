package krewdemo.actor.feature_test {

    import starling.text.TextField;

    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TextFactory;

    //------------------------------------------------------------
    public class ObjectPoolingTester3 extends KrewActor {

        private var _generateCount:int = 0;
        private var _textField:TextField;

        //------------------------------------------------------------
        public override function init():void {
            _textField = _makeText();
            addText(_textField);

            addPeriodicTask(0.01, function():void {
                if (krew.rand(100) > 50) { return; }

                for (var i:int=0;  i < 5;  ++i) {
                    var depth:Number = krew.rand(0.1, 1.0);
                    var color:uint   = krew.hsv2intWithRand(0, 360, 0.4, 1.0, 0.2, 0.6);
                    createActor(StarParticlePooled2.getObject(depth, color));
                    ++_generateCount;
                }
            });
        }

        private function _makeText(str:String="", fontName:String="tk_courier"):TextField {
            var text:TextField = TextFactory.makeText(
                360, 80, str, 14, fontName, 0xffffff,
                15, 35, "left", "top", false
            );
            return text;
        }

        public override function onUpdate(passedTime:Number):void {
            _textField.text = "     generate: " + _generateCount + "\n"
                            + "    new count: " + StarParticlePooled2.numCreate + "\n"
                            + "num on screen: " + StarParticlePooled2.numExists + "\n"
                            + "       pooled: " + StarParticlePooled2.numPooled;
        }

    }
}
