package krewfw_utils.tests {

    import org.flexunit.Assert;
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

    }
}
