package krewfw.data_structure {

    /**
     * Simple priority queue (not so optimized.)
     * Reasonable data structures such as Heap, is not used yet.
     */
    //------------------------------------------------------------
    public class PriorityQueue {

        private var _queue:Vector.<PriorityNode>;
        private var _isDirty:Boolean;

        public var verbose:Boolean = false;

        //------------------------------------------------------------
        public function PriorityQueue() {
            _queue   = new Vector.<PriorityNode>();
            _isDirty = false;
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /**
         * Insert element with priority (small number is high priority.)
         */
        public function enqueue(priority:int, item:*):void {
            var pNode:PriorityNode = new PriorityNode(priority, item);
            _queue.push(pNode);
            _isDirty = true;

            if (verbose) {
                trace("[PriorityQueue :: enqueue] priority:", priority);
                dumpPriority();
            }
        }

        /**
         * Remove and get top-priority element. Multiple elements that have
         * same priority are returned in no particular order.
         * If queue is empty, return null.
         */
        public function dequeue():* {
            if (verbose) {
                trace("[PriorityQueue :: dequeue] length:", _queue.length);
            }
            if (!_queue.length) { return null; }

            if (_isDirty) { _sort(); }
            var topItem:* = _queue.pop().item;

            if (verbose) { dumpPriority(); }
            return topItem;
        }

        /**
         * Get top-priority element without removing it. Multiple elements that
         * have same priority are returned in no particular order.
         * If queue is empty, return null.
         */
        public function peek():* {
            if (!_queue.length) { return null; }

            if (_isDirty) { _sort(); }
            return _queue[_queue.length - 1].item;
        }

        /**
         * Clear the queue.
         */
        public function clear():void {
            for (var i:int = 0;  i < _queue.length; ++i) {
                _queue[i] = null;
            }
            _queue.length = 0;
            _isDirty      = false;
        }

        /**
         * Kill reference for GC.
         */
        public function dispose():void {
            clear();
            _queue = null;
        }

        /**
         * Get the number of elements of queue.
         */
        public function get length():int {
            return _queue.length;
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _sort():void {
            _queue.sort(_sortFunc);
            _isDirty = false;
        }

        /**
         * Keep top-priority element at end of Array to use pop() instead of shift().
         */
        private function _sortFunc(a:PriorityNode, b:PriorityNode):int {
            if (a.priority == b.priority) { return 0; }
            return (a.priority > b.priority) ? -1 : 1;
        }

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function dumpPriority():void {
            var priorities:Array = [];
            for each (var item:PriorityNode in _queue) {
                priorities.push(item.priority);
            }
            trace(" -", priorities);
        }

    }
}

//====================================================================
internal class PriorityNode {

    public var priority:int;
    public var item:*;

    public function PriorityNode(priority:int, item:*) {
        this.priority = priority;
        this.item     = item;
    }

}
