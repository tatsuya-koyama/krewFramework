package krewfw.utils.as3 {

    /**
     * Seedable random generator using XorShift.
     */
    //------------------------------------------------------------
    public class KrewRandom {

        private var x:uint = 123456789;
        private var y:uint = 362436069;
        private var z:uint = 521288629;
        private var w:uint = 88675123;
        private var t:uint;

        public function KrewRandom(seed:uint=88675123) {
            _setSeed(seed);
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        public static function getUintWithSeed(seed:uint):uint {
            var random:KrewRandom = new KrewRandom(seed);
            return random.getUint();
        }

        /**
         * Example:
         * <pre>
         *   getUint()  -> any of 0 to UINT_MAX
         *   getUint(5) -> any of 0, 1, 2, 3, 4
         * </pre>
         */
        public function getUint(mod:uint=0):uint {
            if (!mod) {
                return _genUint();
            }

            return _genUint() % mod;
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _genUint():uint {
            t = x ^ (x << 11);
            x = y;
            y = z;
            z = w;
            w = (w ^ (w >> 19)) ^ (t ^ (t >> 8));
            return w;
        }

        /**
         * [Note] XorShift は乱数生成器として軽量で手頃だが、
         *        初期に生成される値の並びが偏りやすい傾向がある。
         *        ここでは seed の値を設定した後に数回読み飛ばしを行うことで
         *        この偏りを回避する。
         */
        private function _setSeed(seed:uint):void {
            x = seed = 1812433253 * (seed ^ (seed >> 30)) + 0;
            y = seed = 1812433253 * (seed ^ (seed >> 30)) + 1;
            z = seed = 1812433253 * (seed ^ (seed >> 30)) + 2;
            w = seed = 1812433253 * (seed ^ (seed >> 30)) + 3;

            for (var i:int = 0;  i < 8;  ++i) {
                _genUint();
            }
        }

    }
}
