package krewfw_core_internal.tests {

    import org.flexunit.Assert;

    import krewfw.core.KrewGameObject;
    import krewfw.core_internal.NotificationService;

    public class NotificationServiceTestCase {

        [Test]
        public function testBroadcast():void {
            var notificationService:NotificationService = new NotificationService();
            var subscriber:KrewGameObject = new KrewGameObject();

            var result:int = 0;
            var callback:Function = function(eventArg:Object):void {
                result = eventArg.val;
            }
            notificationService.addListener(
                subscriber, 'hoge_msg', callback
            );
            notificationService.postMessage(
                'hoge_msg', {val: 123}
            );
            notificationService.broadcastMessage();

            Assert.assertEquals(result, 123);
        }

    }
}
