package krewfw.core_internal {

    import flash.utils.Dictionary;

    import krewfw.utils.krew;
    import krewfw.core.KrewGameObject;

    //------------------------------------------------------------
    public class NotificationService {

        private var _publishers:Dictionary = new Dictionary();
        private var _listenerCount:int = 0;
        private var _messageQueue:Vector.<Object> = new Vector.<Object>();

        //------------------------------------------------------------
        public function NotificationService() {

        }

        public function addListener(listener:KrewGameObject,
                                    eventType:String, callback:Function):void {
            if (!_publishers[eventType]) {
                _publishers[eventType] = new NotificationPublisher(eventType);
                krew.fwlog('+++ create publisher: ' + eventType);
            }

            _publishers[eventType].addListener(listener, callback);
        }

        public function removeListener(listener:KrewGameObject, eventType:String):Boolean {
            if (!_publishers[eventType]) {
                krew.fwlog('[Error] Event publisher is absent: ' + eventType);
                return false;
            }

            _publishers[eventType].removeListener(listener);
            if (_publishers[eventType].numListener == 0) {
                delete _publishers[eventType];
                krew.fwlog('--- delete publisher: ' + eventType);
            }
            return true;
        }

        public function postMessage(eventType:String, eventArgs:Object):void {
            _messageQueue.push({
                type: eventType,
                args: eventArgs
            });
        }

        public function broadcastMessage():void {
            if (_messageQueue.length == 0) { return; }

            var processingMsgs:Vector.<Object> = _messageQueue.slice(); // copy vector
            _messageQueue = new Vector.<Object>(); // clear vector

            for each (var msg:Object in processingMsgs) {
                var eventType:String = msg.type;
                if (!_publishers[eventType]) { continue; }

                var eventArgs:Object = msg.args;
                var publisher:NotificationPublisher = _publishers[eventType];
                publisher.publish(eventArgs);
            }

            // ToDo: for の中で Message 投げられてたら再帰
        }
    }
}
