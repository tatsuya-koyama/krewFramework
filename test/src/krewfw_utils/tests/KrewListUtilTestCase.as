package krewfw_utils.tests {

    import org.flexunit.Assert;
    import org.flexunit.assertThat;
    import mx.utils.ObjectUtil;

    import krewfw.utils.krew;

    public class KrewListUtilTestCase {

        [Test]
        public function test_count():void {
            var filter:Function = function(item:*):Boolean {
                return (item % 2 == 0);
            };
            Assert.assertEquals(4, krew.list.count([2, 1, 4, 5, 8, 3, 4], filter));
        }

        [Test]
        public function test_find():void {
            var tester:Function = function(item:*):Boolean {
                return (item % 5 == 0);
            };
            Assert.assertEquals(15, krew.list.find([3, 7, 15, 8, 5, 10, 2], tester));
        }

    }
}
