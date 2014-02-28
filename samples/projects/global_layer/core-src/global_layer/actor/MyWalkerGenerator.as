package global_layer.actor {

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class MyWalkerGenerator extends KrewActor {

        //------------------------------------------------------------
        public function MyWalkerGenerator(span:Number=1.0, scale:Number=1.0, color:uint=0xffffff) {
            addInitializer(function():void {
                cyclic(span, function():void {
                    createActor(new MyWalker(scale, color));
                });
            });
        }

    }
}
