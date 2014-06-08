package krewfw.utils.as3 {

    public interface KrewPoolable {

        /** Called on instanciation. */
        function onPooledObjectCreate(params:Object):void;

        /** Called after instanciation or on reuse. */
        function onPooledObjectInit(params:Object):void;

        /** Called on reuse. */
        function onRetrieveFromPool(params:Object):void;

        /** Called on enter pool. */
        function onPooledObjectRecycle():void;

        /** Called when instance is disposed from pool. */
        function onDisposeFromPool():void;

    }
}
