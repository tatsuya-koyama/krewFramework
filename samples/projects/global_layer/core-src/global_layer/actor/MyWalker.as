package global_layer.actor {

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class MyWalker extends KrewActor {

        private var _scale:Number;

        //------------------------------------------------------------
        public function MyWalker(scale:Number=1.0, color:uint=0xffffff) {
            _scale = scale;

            var that:KrewActor = this;
            addInitializer(function():void {
                addImage(getImage("rectangle_taro"), 100, 100);
                that.color = color;

                x = krew.rand(0, 480);
                y = -50;
                scaleX = scaleY = _scale;
            });
        }

        public override function onUpdate(passedTime:Number):void {
            y += 200 * passedTime * _scale;

            if (y > 320 + 50) { passAway(); }
        }

    }
}
