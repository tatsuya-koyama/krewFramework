package krewfw_utils.tests {

    import org.flexunit.Assert;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
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

        [Test]
        public function test_unique():void {
            assertThat(
                krew.list.unique([3, 1, 2, 2, 4, 1, 3]),
                array([3, 1, 2, 4])
            );

            assertThat(
                krew.list.unique([2, 5, 2, 3, -1, 4, 4, 0, 1, 5, -1, 6, 2]),
                array([2, 5, 3, -1, 4, 0, 1, 6])
            );

            assertThat(
                krew.list.unique(["Apple", "Apple", "Orange", "Grape", "Orange"]),
                array(["Apple", "Orange", "Grape"])
            );

            assertThat(
                krew.list.unique([1, 1, "BBB", 3, "AAA", 3, null, 2, "AAA", 2, null, 1, 1]),
                array([1, "BBB", 3, "AAA", null, 2])
            );

            assertThat(
                krew.list.unique([]),
                array([])
            );
        }

        [Test]
        public function test_sortedUnique():void {
            assertThat(
                krew.list.sortedUnique([3, 1, 2, 2, 4, 1, 3]),
                array([1, 2, 3, 4])
            );

            assertThat(
                krew.list.sortedUnique(["Banana", "Apple", "Apple", "Orange", "Grape", "Orange"]),
                array(["Apple", "Banana", "Grape", "Orange"])
            );

            assertThat(
                krew.list.sortedUnique(["Banana", 1, "Apple", 3, "1", "Banana", 3, "2.4", 2.4]),
                array(["1", 1, "2.4", 2.4, 3, "Apple", "Banana"])
            );

            assertThat(
                krew.list.sortedUnique([null]),
                array([null])
            );

            assertThat(
                krew.list.sortedUnique([null, 1]),
                array([1, null])
            );

            assertThat(
                krew.list.sortedUnique([]),
                array([])
            );
        }

    }
}
