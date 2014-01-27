package krewfw.utils.swiss_knife {

    /**
     * Singleton Army knife for string processing.
     */
    //------------------------------------------------------------
    public class KrewStringUtil {

        //------------------------------------------------------------
        // Singleton interface
        //------------------------------------------------------------

        private static var _instance:KrewStringUtil;

        public function KrewStringUtil() {
            if (_instance) {
                throw new Error("[KrewStringUtil] Cannot instantiate singleton.");
            }
        }

        public static function get instance():KrewStringUtil {
            if (!_instance) {
                _instance = new KrewStringUtil();
            }
            return _instance;
        }

        //------------------------------------------------------------

        /**
         * 同じものが mx.utils.StringUtil.repeat にもあるが、
         * それを使うと ASDoc が何故か失敗する…
         */
        public function repeat(strUnit:String, count:int):String {
            if (count <= 0) { return ""; }

            var resultStr:String = strUnit;
            for (var i:int = 1;  i < count;  ++i) {
                resultStr += strUnit;
            }
            return resultStr;
        }

    }
}
