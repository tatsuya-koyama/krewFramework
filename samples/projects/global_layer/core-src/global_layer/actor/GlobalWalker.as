package global_layer.actor {

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class GlobalWalker extends KrewActor {

        //------------------------------------------------------------
        public function GlobalWalker() {
            addInitializer(function():void {

                // You must use global assets for global layer view.
                addImage(getImage("rectangle_taro"), 100, 100);
                color = 0xccff55;

                x = -50;
                y = 300;
            });
        }

        public override function onUpdate(passedTime:Number):void {
            x += 220 * passedTime;

            if (x > 480 + 50) { passAway(); }
        }

    }
}
