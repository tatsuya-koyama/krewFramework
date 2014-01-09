package krewfw_core_internal {

    import krewfw_core_internal.tests.CollisionShapeTestCase;
    import krewfw_core_internal.tests.NotificationServiceTestCase;
    //import krewfw_core_internal.tests.StateMachineTestCase;

    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public class KrewCoreInternalTestSuite {
        public var test_01:CollisionShapeTestCase;
        public var test_02:NotificationServiceTestCase;
        //public var test_03:TkStateMachineTestCase;
    }
}
