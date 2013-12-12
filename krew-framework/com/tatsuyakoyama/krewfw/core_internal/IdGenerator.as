package com.tatsuyakoyama.krewfw.core_internal {

    import starling.errors.AbstractClassError;

    public class IdGenerator {

        private static var _count:int = 0;

        //------------------------------------------------------------
        public function IdGenerator() {
            throw new AbstractClassError();
        }

        public static function generateId():int {
            ++_count;
            if (_count < 1) { _count = 1; }  // consider overflow
            return _count;
        }
    }
}
