package krewdemo.scene {

    import krewdemo.actor.feature_test.InfoPopUp;
    import krewdemo.actor.performance_test.ArraySpliceTester;

    //------------------------------------------------------------
    public class ArrayPerformanceTestScene1 extends FeatureTestSceneBase {

        //------------------------------------------------------------
        public override function initAfterLoad():void {
            _bgColor = 0x333333;
            super.initAfterLoad();

            setUpActor('l-front', new ArraySpliceTester());

            setUpActor('l-ui', new InfoPopUp(
                  "- Array.splice() performance test.\n"
            ));
        }

    }
}
