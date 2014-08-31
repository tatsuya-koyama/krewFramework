package krewfw_utils.tests {

    import org.flexunit.Assert;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import org.hamcrest.number.closeTo;
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

        [Test]
        public function test_max():void {
            Assert.assertEquals( 0, krew.max());
            Assert.assertEquals( 1, krew.max(1));
            Assert.assertEquals( 3, krew.max(2, 3));
            Assert.assertEquals( 4, krew.max(4, -3, 2));
            Assert.assertEquals(-1, krew.max(-2, -1, -3));
            Assert.assertEquals( 0, krew.max(-8, -3, 0, -1));
            Assert.assertEquals( 7, krew.max(1, 7, 3, 2.5));
            Assert.assertEquals( 7, krew.max(1, 7, null, 2.5));
            Assert.assertEquals( 5, krew.max(4, 5, 5, 5, 4, 5));
        }

        [Test]
        public function test_min():void {
            Assert.assertEquals( 0, krew.min());
            Assert.assertEquals( 1, krew.min(1));
            Assert.assertEquals( 2, krew.min(2, 3));
            Assert.assertEquals(-3, krew.min(4, -3, 2));
            Assert.assertEquals(-3, krew.min(-2, -1, -3));
            Assert.assertEquals( 0, krew.min(9, 3, 0, 1));
            Assert.assertEquals( 1, krew.min(1, 7, 3, 2.5));
            Assert.assertEquals( 1, krew.min(7, 1, null, 2.5));
            Assert.assertEquals( 4, krew.min(4, 5, 5, 5, 4, 5));
        }

        [Test]
        public function test_getHue():void {
            Assert.assertEquals(  0, krew.getHue(0xff0000));
            Assert.assertEquals( 60, krew.getHue(0xffff00));
            Assert.assertEquals(120, krew.getHue(0x00ff00));
            Assert.assertEquals(180, krew.getHue(0x00ffff));
            Assert.assertEquals(240, krew.getHue(0x0000ff));
            Assert.assertEquals(300, krew.getHue(0xff00ff));
        }

        [Test]
        public function test_getSaturation():void {
            Assert.assertEquals(0, krew.getSaturation(0));
            Assert.assertEquals(1, krew.getSaturation(0xff0000));
            Assert.assertEquals(1, krew.getSaturation(0x00ff00));
            Assert.assertEquals(1, krew.getSaturation(0x0000ff));
            Assert.assertEquals(1, krew.getSaturation(0x8800ff));
            assertThat(0.466, closeTo(krew.getSaturation(0x8888ff), 0.01));
        }

        [Test]
        public function test_getBrightness():void {
            Assert.assertEquals(0  , krew.getBrightness(0));
            Assert.assertEquals(1  , krew.getBrightness(0x0000ff));
            Assert.assertEquals(1  , krew.getBrightness(0x00ffff));
            Assert.assertEquals(1  , krew.getBrightness(0x8888ff));
            Assert.assertEquals(1  , krew.getBrightness(0xffffff));
            assertThat(0.50, closeTo(krew.getBrightness(0x808080), 0.01));
        }

    }
}
