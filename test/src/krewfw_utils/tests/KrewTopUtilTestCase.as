package krewfw_utils.tests {

    import org.flexunit.Assert;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import mx.utils.ObjectUtil;

    import krewfw.utils.krew;

    public class KrewTopUtilTestCase {

        [Test]
        public function test_flattenObject():void {
            var srcObj:Object = {
                hoge: 123,
                fuga: {
                    piyo: {
                        foo: 456,
                        bar: true
                    },
                    foobar: 0
                },
                hogehoge: null
            };

            var expectedObj:Object = {
                'hoge'          : 123,
                'fuga.piyo.foo' : 456,
                'fuga.piyo.bar' : true,
                'fuga.foobar'   : 0,
                hogehoge        : null
            };

            var testingObj:Object = krew.flattenObject(srcObj);
            Assert.assertEquals(0, ObjectUtil.compare(testingObj, expectedObj));
        }

        [Test]
        public function test_range():void {
            assertThat([0, 1, 2, 3, 4],      array(krew.range(5)));
            assertThat([3, 4, 5, 6, 7],      array(krew.range(3, 7)));
            assertThat([3],                  array(krew.range(3, 3.1)));
            assertThat([2.0, 2.5, 3.0, 3.5], array(krew.range(2, 3.5, 0.5)));

            assertThat([7, 6, 5, 4, 3],      array(krew.range(7, 3)));
            assertThat([7],                  array(krew.range(7, 7)));
            assertThat([7],                  array(krew.range(7, 6.9)));
            assertThat([3.0, 2.5, 2.0],      array(krew.range(3, 2, -0.5)));
            assertThat([],                   array(krew.range(0)));

            Assert.assertEquals(null, krew.range(7, 3, 1));
        }

    }
}
