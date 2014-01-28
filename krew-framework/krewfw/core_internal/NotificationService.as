package krewfw.core_internal {

    import flash.utils.Dictionary;

    import krewfw.core.KrewGameObject;
    import krewfw.utils.krew;

    //------------------------------------------------------------
    public class NotificationService {

        public static var MAX_LOOP_COUNT:int = 8;

        private var _publishers:Dictionary = new Dictionary();
        private var _listenerCount:int = 0;
        private var _messageQueue:Vector.<Object> = new Vector.<Object>();

        //------------------------------------------------------------
        public function NotificationService() {}

        public function addListener(listener:KrewGameObject,
                                    eventType:String, callback:Function):void {
            if (!_publishers[eventType]) {
                _publishers[eventType] = new NotificationPublisher(eventType);
                krew.fwlog('+++ create publisher: ' + eventType + ' +++');
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
                krew.fwlog('--- delete publisher: ' + eventType + ' ---');
            }
            return true;
        }

        public function postMessage(eventType:String, eventArgs:Object):void {
            _messageQueue.push({
                type: eventType,
                args: eventArgs
            });
        }

        public function broadcastMessage(recallCount:int=0):void {
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

            if (_messageQueue.length == 0) { return; }

            // イベントのハンドリングの中でさらに Message が投げられていた場合、
            // 再帰して投げられるイベントがなくなるまで処理を継続する。
            // ただし Actor 間でイベントを投げ合うループ構造ができてしまうと無限ループになるため
            // セーフティとして試行回数には制限をかける
            if (recallCount < MAX_LOOP_COUNT) {
                this.broadcastMessage(recallCount + 1);
            } else {
                // 処理しきれなかったイベントは諦める（そうしないとイベントの数が肥大化しうるから）
                // * そもそもここが呼ばれる場合は設計が間違っている。
                //   このログは出力されないべきである
                dumpMessageQueue();
                _messageQueue = new Vector.<Object>();
                krew.fwlog('[Warning!!] Event handling seems to be infinite loop!');
            }
        }

        //------------------------------------------------------------
        // debug method
        //------------------------------------------------------------

        public function dumpMessageQueue():void {
            var types:Vector.<Object> = new Vector.<Object>;
            types = _messageQueue.map(function(elem:Object, i:int, list:Vector.<Object>):Object {
                return elem.type;
            });
            krew.fwlog('[NotificationService] message dump: ' + types.join(", "));
        }

    }
}
