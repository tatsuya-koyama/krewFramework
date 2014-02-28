package global_layer.actor {

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class GlobalWalkerGenerator extends KrewActor {

        //------------------------------------------------------------
        public function GlobalWalkerGenerator(span:Number=1.0) {
            addInitializer(function():void {
                cyclic(span, function():void {
                    createActor(new GlobalWalker());
                });
            });
        }

    }
}
