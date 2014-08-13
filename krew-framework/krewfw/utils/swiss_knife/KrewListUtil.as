package krewfw.utils.swiss_knife {

    import flash.utils.Dictionary;

    import krewfw.utils.krew;

    /**
     * Singleton Army knife for Array processing.
     * (Use this if you cannot find necessary methods in built-in Array.)
     */
    //------------------------------------------------------------
    public class KrewListUtil {

        //------------------------------------------------------------
        // Singleton interface
        //------------------------------------------------------------

        private static var _instance:KrewListUtil;

        public function KrewListUtil() {
            if (_instance) {
                throw new Error("[KrewListUtil] Cannot instantiate singleton.");
            }
        }

        public static function get instance():KrewListUtil {
            if (!_instance) {
                _instance = new KrewListUtil();
            }
            return _instance;
        }

        //------------------------------------------------------------

        /**
         * Returns the number of elements in the list that match iterator function.
         * (Just counts up, Does not make an array object.)
         *
         * @param list Target Array.
         * @param iterator Filter function
         * @example
         * <pre>
         *     krew.list.count([2, 1, 4, 0], function(item:*):Boolean {
         *         return (item > 1);
         *     });
         *         -> 2
         * </pre>
         */
        public function count(list:Array, iterator:Function):int {
            var num:int = 0;
            for each (var item:* in list) {
                if (iterator(item)) { ++num; }
            }
            return num;
        }

        /**
         * Returns a random element in the array.
         * If array is empty, returns null.
         */
        public function sample(list:Array):* {
            if (list.length == 0) { return null; }

            var index:int = krew.randInt(0, list.length - 1);
            return list[index];
        }

        /**
         * Returns the first element that passes a test iterator.
         * If no value passes the test, returns null.
         * When the function finds an acceptable element, it doesn't traverse the entire list.
         *
         * @param list Target Array.
         * @param iterator Tester Function: function(item:*):Boolean
         */
        public function find(list:Array, iterator:Function):* {
            for each (var item:* in list) {
                if (iterator(item)) { return item; }
            }
            return null;
        }

        /**
         * Removes all duplicate elements in the array.
         * Non-destructive, and order is maintained.
         * <pre>
         * Example:
         *     [3, 1, 2, 2, 4, 1, 3]  ->  [3, 1, 2, 4]
         *     ["Apple", "Apple", "Orange", "Grape", "Orange"]  ->  ["Apple", "Orange", "Grape"]
         *     [1, 1, "BBB", 3, "AAA", 3, null, 2, "AAA", 2, null, 1, 1]  ->  [1, "BBB", 3, "AAA", null, 2]
         *     []  ->  []
         * </pre>
         */
        public function unique(list:Array):Array {
            var known:Dictionary = new Dictionary();
            var result:Array = [];
            for each (var item:* in list) {
                if (!known[item]) {
                    result.push(item);
                    known[item] = true;
                }
            }
            return result;
        }

        /**
         * Sort and removes all duplicate elements in the array.
         * Non-destructive. Sort method is default of AS3's Array class.
         * <pre>
         * Example:
         *     [3, 1, 2, 2, 4, 1, 3]  ->  [1, 2, 3, 4]
         *     ["Banana", "Apple", "Apple", "Orange", "Grape", "Orange"]  ->  ["Apple", "Banana", "Grape", "Orange"]
         *     ["Banana", 1, "Apple", 3, "1", "Banana", 3, "2.4", 2.4]  ->  ["1", 1, "2.4", 2.4, 3, "Apple", "Banana"]
         *     []  ->  []
         * </pre>
         */
        public function sortedUnique(srcList:Array):Array {
            if (srcList.length == 0) { return []; }

            var list:Array = srcList.slice();  // duplicate
            list.sort();

            var result:Array = [];
            var prev:* = null;
            if (list[0] == null) { prev = false; }

            for each (var item:* in list) {
                if (item !== prev) {
                    result.push(item);
                    prev = item;
                }
            }
            return result;
        }

    }
}
