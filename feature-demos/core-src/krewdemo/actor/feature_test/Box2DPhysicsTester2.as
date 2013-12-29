package krewdemo.actor.feature_test {

    //------------------------------------------------------------
    public class Box2DPhysicsTester2 extends Box2DPhysicsTester1 {

        //------------------------------------------------------------
        public function Box2DPhysicsTester2() {
            addInitializer(function():void {
                addPeriodicTask(0.02, function():void {
                    _addRandomBox(10, 20);
                });
            });
        }

    }
}
