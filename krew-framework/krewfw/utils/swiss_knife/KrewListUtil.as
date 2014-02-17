package krewfw.utils.swiss_knife {

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

    }
}
