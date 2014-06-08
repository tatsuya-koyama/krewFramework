package krewfw.core {

    import krewfw.utils.as3.KrewObjectPool;
    import krewfw.utils.as3.KrewPoolable;

    /**
     * To make poolable actor, extends KrewPoolableActor and implements
     * in subclasses like this:
     *
     * <pre>
     * public class YourPoolableActorClass extends KrewPoolableActor {
     *
     *     private static var _objectPool:KrewObjectPool = new KrewObjectPool(YourPoolableActorClass);
     *
     *     protected override function onRecycle():void {
     *         _objectPool.recycle(this);
     *     }
     *
     *     public static function getObject(arg1:Number, arg2:uint):YourPoolableActorClass {
     *         var params:Object = {
     *             arg1: arg1,
     *             arg2: arg2
     *         };
     *         return _objectPool.getObject(params) as YourPoolableActorClass;
     *     }
     *
     *     public static function disposePool():void {
     *         _objectPool.dispose();
     *     }
     *
     *     ...
     * }
     * </pre>
     */
    //------------------------------------------------------------
    public class KrewPoolableActor extends KrewActor implements KrewPoolable {

        //------------------------------------------------------------
        /**
         * Poolable actor's constructor should be able to receive zero arguments
         * because KrewObjectPool instanciates it with no arguments.
         * You can init instance in onPooledObjectCreate() handler.
         */
        public function KrewPoolableActor() {
            poolable = true;
        }

        //------------------------------------------------------------
        // implementation of KrewPoolable
        //------------------------------------------------------------

        public function onPooledObjectCreate(params:Object):void {
            // Override in subclasses
        }

        public function onPooledObjectInit(params:Object):void {
            // Override in subclasses
        }

        public function onRetrieveFromPool(params:Object):void {
            _retrieveFromPool();
        }

        public function onPooledObjectRecycle():void {}

        public function onDisposeFromPool():void {
            _disposeFromPool();
        }

    }
}
