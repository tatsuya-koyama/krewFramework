package krewfw.core_internal {

    import flash.utils.Dictionary;

    import krewfw.utils.krew;
    import krewfw.core.KrewGameObject;

    //------------------------------------------------------------
    public class NotificationPublisher {

        private var _eventType:String;
        private var _listeners:Dictionary = new Dictionary();
        private var _listenerCount:int = 0;
        private var _numListener:int = 0;

        //------------------------------------------------------------
        public function get numListener():int {
            return _numListener;
        }

        //------------------------------------------------------------
        public function NotificationPublisher(eventType:String='anonymous') {
            _eventType = eventType;
        }

        public function addListener(listener:KrewGameObject, callback:Function):void {
            _listeners[listener.id] = callback;
            ++_numListener;
            // krew.fwlog('+++ add listener: [id ' + listener.id + '] '
            //             + _eventType + ' (total ' + _numListener + ')');
        }

        public function removeListener(listener:KrewGameObject):Boolean {
            if (!_listeners[listener.id]) {
                krew.fwlog('[Error] Listener is not listening: [id '
                               + listener.id + ']');
                return false;
            }

            delete _listeners[listener.id];
            --_numListener;
            // krew.fwlog('--- remove listener: [id ' + listener.id + '] '
            //             + _eventType + ' (total ' + _numListener + ')');
            return true;
        }

        public function publish(eventArgs:Object):void {
            for each (var callback:Function in _listeners) {
                callback(eventArgs);
            }
        }
    }
}
