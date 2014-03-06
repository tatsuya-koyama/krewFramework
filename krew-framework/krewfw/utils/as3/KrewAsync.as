package krewfw.utils.as3 {

    /**
     * Flexible asynchronous tasker.
     *
     * Usage:
     * <pre>
     *     //--- Basic sequential task
     *     var async:KrewAsync = new KrewAsync({
     *         serial : [function_1, function_2, function_3],
     *         error  : _onErrorHandler,
     *         anyway : _onFinallyHandler
     *     });
     *     async.go();
     *
     *
     *     //--- Parallel task
     *     var async:KrewAsync = new KrewAsync({
     *         parallel: [function_1, function_2, function_3],
     *         error   : _onErrorHandler,
     *         anyway  : _onFinallyHandler
     *     });
     *     async.go();
     *
     *     * Throws error if both 'serial' and 'parallel' are specified.
     *
     *
     *     //--- Function receives KrewAsync instance,
     *     //    and you should call done() or fail().
     +
     *     var async:KrewAsync = new KrewAsync({
     *         serial: [
     *             function(async:KrewAsync):void {
     *                 if (TASK_IS_SUCCEEDED) {
     *                     async.done();
     *                 } else {
     *                     async.fail();
     *                 }
     *             }
     *         ]
     *     });
     *
     *
     *     //--- Sub task
     *     var async:KrewAsync = new KrewAsync({
     *         serial: [
     *             function_1,
     *             function_2,
     *             {parallel: [
     *                 function_3,
     *                 function_4,
     *                 {serial: [
     *                     function_5,
     *                     function_6
     *                 ]}
     *             ]},
     *             function_7
     *         ],
     *         error  : _onErrorHandler,
     *         anyway : _onFinallyHandler
     *     });
     *     async.go();
     *
     *     [Sequence]:
     *                   |3 ------>|
     *                   |         |
     *         1 -> 2 -> |4 ------>| -> 7 -> anyway
     *                   |         |
     *                   |5 -> 6 ->|
     *
     * </pre>
     *
     * @param asyncDef Object or Function or instance of KrewAsync. Example:
     * <pre>
     *     var async:KrewAsync = new KrewAsync(<asyncDef>);
     *
     *     <asyncDef> ::= {
     *         single  : function(async:KrewAsync):void {}  // KrewAsync uses internally
     *         // OR
     *         serial  : [<asyncDef>, ... ]
     *         // OR
     *         parallel: [<asyncDef>, ... ]
     *
     *         error   : function():void {},  // optional
     *         anyway  : function():void {}   // optional
     *     }
     *
     *     * If <asyncDef> == Function, then it is converted into:
     *         {single: Function}
     *
     *     * You can use class instances instead of asyncDef object:
     *
     *         public class MyKrewAsyncTask extends KrewAsync {
     *             public function MyKrewAsyncTask() {
     *                 super({
     *                     parallel: [method_1, method_2, method_3]
     *                 });
     *             }
     *         }
     *
     *         var async:KrewAsync = new KrewAsync({
     *             serial: [
     *                 function_1,
     *                 new MyKrewAsyncTask(),
     *                 function_2
     *             ]
     *         });
     * </pre>
     */
    //------------------------------------------------------------
    public class KrewAsync {

        private var _myTask:Function;
        private var _errorHandler:Function;
        private var _finallyHandler:Function;

        private var _serialTasks  :Vector.<KrewAsync>;
        private var _parallelTasks:Vector.<KrewAsync>;

        private var _serialTaskIndex:int = 0;
        private var _onComplete:Function = function():void {};

        public static const UNDEF   :int = 1;
        public static const RESOLVED:int = 2;
        public static const REJECTED:int = 3;

        private var _state:int = KrewAsync.UNDEF;

        //------------------------------------------------------------
        public function KrewAsync(asyncDef:*) {
            if (asyncDef is Function) {
                _initWithFunction(asyncDef);
                return;
            }
            if (asyncDef is KrewAsync) {
                _initWithKrewAsync(asyncDef);
                return;
            }
            if (asyncDef is Array) {
                _initWithArray(asyncDef);
                return;
            }
            if (asyncDef is Object) {
                _initWithObject(asyncDef);
                return;
            }
        }

        //------------------------------------------------------------
        // accessors
        //------------------------------------------------------------

        public function get myTask()        :Function { return _myTask; }
        public function get errorHandler()  :Function { return _errorHandler; }
        public function get finallyHandler():Function { return _finallyHandler; }

        public function get serialTasks()  :Vector.<KrewAsync> { return _serialTasks; }
        public function get parallelTasks():Vector.<KrewAsync> { return _parallelTasks; }

        public function get state():int { return _state; }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        public function go(onComplete:Function=null):void {
            if (onComplete != null) {
                _onComplete = onComplete;
            }

            if (_myTask != null) {
                _myTask(this);
                return;
            }

            if (_serialTasks != null) {
                _kickNextSerialTask();
                return;
            }

            if (_parallelTasks != null) {
                _kickParallelTasks();
                return;
            }
        }

        public function done():void {
            _state = KrewAsync.RESOLVED;
            _finalize();
        }

        public function fail():void {
            _state = KrewAsync.REJECTED;
            _finalize();
        }

        //------------------------------------------------------------
        // initializer
        //------------------------------------------------------------

        private function _initWithObject(asyncDef:Object):void {
            _validateInitObject(asyncDef);

            if (asyncDef.single   != null) { _myTask = asyncDef.single; }
            if (asyncDef.serial   != null) { _serialTasks   = _makeChildren(asyncDef.serial); }
            if (asyncDef.parallel != null) { _parallelTasks = _makeChildren(asyncDef.parallel); }

            if (asyncDef.error    != null) { _errorHandler   = asyncDef.error; }
            if (asyncDef.anyway   != null) { _finallyHandler = asyncDef.anyway; }
        }

        private function _validateInitObject(asyncDef:Object):void {
            var exclusiveDefCount:uint = 0;
            if (asyncDef.single   != null) { ++exclusiveDefCount; }
            if (asyncDef.serial   != null) { ++exclusiveDefCount; }
            if (asyncDef.parallel != null) { ++exclusiveDefCount; }

            if (exclusiveDefCount != 1) {
                throw new Error("[KrewAsync] Error: Invalid async task definition.");
            }
        }

        private function _makeChildren(asyncDefList:Array):Vector.<KrewAsync> {
            var children:Vector.<KrewAsync> = new Vector.<KrewAsync>;

            for each (var def:* in asyncDefList) {
                var async:KrewAsync = (def is KrewAsync) ? def : new KrewAsync(def);
                children.push(async);
            }
            return children;
        }

        private function _initWithFunction(asyncDef:Function):void {
            _initWithObject({
                single: asyncDef
            });
        }

        private function _initWithArray(asyncDef:Array):void {
            _initWithObject({
                serial: asyncDef
            });
        }

        private function _initWithKrewAsync(asyncDef:KrewAsync):void {
            _myTask         = asyncDef.myTask;
            _errorHandler   = asyncDef.errorHandler;
            _finallyHandler = asyncDef.finallyHandler;
            _serialTasks    = asyncDef.serialTasks;
            _parallelTasks  = asyncDef.parallelTasks;
        }

        //------------------------------------------------------------
        // task runner
        //------------------------------------------------------------

        private function _kickNextSerialTask():void {
            if (_serialTaskIndex >= _serialTasks.length) {
                done();
                return;
            }

            var nextTask:KrewAsync = _serialTasks[_serialTaskIndex];
            ++_serialTaskIndex;

            nextTask.go(function(async:KrewAsync):void {
                if (async.state == KrewAsync.RESOLVED) {
                    _kickNextSerialTask();
                } else {
                    _onReject();
                }
            });
        }

        private function _onReject():void {
            if (_errorHandler != null) {
                _errorHandler();
            }
            _finalize();
        }

        private function _finalize():void {
            if (_finallyHandler != null) {
                _finallyHandler();
            }
            _onComplete(this);
        }

        private function _kickParallelTasks():void {
            var doneCount:int = 0;

            for each (var task:KrewAsync in _parallelTasks) {
                task.go(function(async:KrewAsync):void {
                    if (async.state == KrewAsync.RESOLVED) {
                        ++doneCount;
                        if (doneCount == _parallelTasks.length) {
                            done();
                        }
                    } else {
                        _onReject();
                    }
                });
            }
        }

    }
}
