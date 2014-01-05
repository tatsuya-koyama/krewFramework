package krewdemo.actor.feature_test {

    //------------------------------------------------------------
    public class NapePhysicsTester2 extends NapePhysicsTester1 {

        //------------------------------------------------------------
        public function NapePhysicsTester2() {
            addInitializer(function():void {
                addPeriodicTask(0.02, function():void {
                    _addRandomBox(10, 20);
                });
            });
        }

    }
}
