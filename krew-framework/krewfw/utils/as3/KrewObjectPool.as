package krewfw.utils.as3 {

    //------------------------------------------------------------
    public class KrewObjectPool {

        private var _classType:Class;
        private var _pool:Vector.<KrewPoolable>;
        private var _head:uint = 0;

        //------------------------------------------------------------
        public function KrewObjectPool(classType:Class, initialPoolSize:int=100) {
            _classType = classType;
            _pool = new Vector.<KrewPoolable>(initialPoolSize);
        }

        public function get numPooled():int {
            return _head;
        }

        public function getObject(params:Object=null):KrewPoolable {
            var obj:KrewPoolable;

            if (_head == 0) {
                obj = new _classType();
                obj.onPooledObjectCreate(params);
                obj.onPooledObjectInit(params);
            }
            else {
                obj = _pool[_head];
                --_head;

                obj.onRetrieveFromPool(params);
                obj.onPooledObjectInit(params);
            }

            return obj;
        }

        public function recycle(obj:KrewPoolable):void {
            ++_head;
            if (_head >= _pool.length) {
                _pool.push(obj);  // expand vector
            } else {
                _pool[_head] = obj;
            }

            obj.onPooledObjectRecycle();
        }

        public function dispose():void {
            for (var i:int = 0;  i < _pool.length;  ++i) {
                var obj:KrewPoolable = _pool[i];
                if (obj) {
                    obj.onDisposeFromPool();
                }
                _pool[i] = null;
            }
            _head = 0;
        }

    }
}
