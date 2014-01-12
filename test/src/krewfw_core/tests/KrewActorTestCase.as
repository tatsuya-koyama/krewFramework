package krewfw_core.tests {

    import org.flexunit.Assert;

    import krewfw.core.KrewActor;
    import krewfw.core.KrewScene;
    import krewfw.utils.dev_tool.KrewTestUtil;

    public class KrewActorTestCase {

        [Test]
        public function test_basicMessaging():void {
            var scene:KrewScene = KrewTestUtil.getScene();

            var actor1:KrewActor = new KrewActor();
            var actor2:KrewActor = new KrewActor();
            scene.setUpActor(null, actor1);
            scene.setUpActor(null, actor2);

            var signal:int = 0;
            actor1.listen("event_1", function(args:Object):void { signal = args.val; });
            actor2.sendMessage("event_1", {val: 123});

            Assert.assertEquals(signal, 0);

            scene.mainLoop();

            Assert.assertEquals(signal, 123);
        }

    }
}
