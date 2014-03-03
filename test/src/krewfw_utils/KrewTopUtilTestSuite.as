package krewfw_utils {

    import krewfw_utils.tests.KrewTopUtilTestCase;
    import krewfw_utils.tests.KrewListUtilTestCase;
    import krewfw_utils.tests.KrewAsyncTestCase;

    [Suite]
    [RunWith("org.flexunit.runners.Suite")]
    public class KrewTopUtilTestSuite {
        public var test_01:KrewTopUtilTestCase;
        public var test_02:KrewListUtilTestCase;
        public var test_03:KrewAsyncTestCase;
    }
}
