package krewfw.utils.swiss_knife {

    import flash.utils.getQualifiedClassName;

    import krewfw.KrewConfig;
    import krewfw.core.KrewActorAgent;
    import krewfw.utils.as3.KrewAsync;
    import krewfw.utils.as3.KrewRandom;

    /**
     * Singleton Army knife for game coding.
     * Collections of top-level, frequently-used stateless functions.
     *
     * If you import krewfw.utils.krew, you can access to this utilities easily as below:
     * <pre>
     *     import krewfw.utils.krew;
     *
     *     krew.rand(100);            // Top Level utilities
     *     krew.str.repeat('*', 10);  // 2nd Level utilities
     *     ...
     * </pre>
     *
     * And when you're writing KrewActor, it's no longer need to import krew.
     * KrewActor has krew as class member.
     */
    //------------------------------------------------------------
    public class KrewTopUtil {

        //------------------------------------------------------------
        // 2nd level utilities
        //------------------------------------------------------------

        public function get agent():KrewActorAgent {
            return KrewActorAgent.instance;
        }

        public var str:KrewStringUtil = KrewStringUtil.instance;
        public var list:KrewListUtil  = KrewListUtil.instance;

        //------------------------------------------------------------
        // Singleton interface
        //------------------------------------------------------------

        private static var _instance:KrewTopUtil;

        public function KrewTopUtil() {
            if (_instance) {
                throw new Error("[KrewTopUtil] Cannot instantiate singleton.");
            }
        }

        public static function get instance():KrewTopUtil {
            if (!_instance) {
                _instance = new KrewTopUtil();
            }
            return _instance;
        }

        //------------------------------------------------------------
        // Logging
        //------------------------------------------------------------

        public function log(msg:String, traceLevel:int=1):void {
            if (KrewConfig.GAME_LOG_VERBOSE == 0) { return; }

            if (KrewConfig.GAME_LOG_VERBOSE == 1) {
                trace(msg);
                return;
            }

            _log(msg, traceLevel + 1);
        }

        /**
         * krewFramework の中から呼んでいるシステムログ。
         * フレームワーク利用者はこちらではなく log を利用してほしい。
         * （そうすれば、フレームワーク側とゲーム側でログの出力レベルを個別に変えることができる）
         */
        public function fwlog(msg:String, traceLevel:int=1):void {
            if (KrewConfig.FW_LOG_VERBOSE == 0) { return; }

            if (KrewConfig.FW_LOG_VERBOSE == 1) {
                trace(msg);
                return;
            }

            _log(msg, traceLevel + 1);
        }

        private function _log(msg:String, traceLevel:int=1):void {
            var error:Error = new Error();
            var functionName:String = _getFunctionName(error, traceLevel);
            var lineNumber:String   = _getLineNumber(error, traceLevel);
            trace(functionName + ' ::: ' + lineNumber + ' >>> ' + msg);
        }

        private function _getFunctionName(e:Error, traceBackLevel:int=0):String {
            var stackTrace:String = e.getStackTrace();
            var traceLines:Array  = stackTrace.split('\n');
            var targetLine:String = traceLines[traceBackLevel + 1];
            var startIndex:int = 0;
            var endIndex:int   = 0;
            startIndex = targetLine.indexOf('at ', 0);
            endIndex   = targetLine.indexOf('()',  startIndex);
            return targetLine.substring(startIndex + 3, endIndex);
        }

        private function _getLineNumber(e:Error, traceBackLevel:int=0):String {
            var stackTrace:String = e.getStackTrace();
            var traceLines:Array  = stackTrace.split('\n');
            var targetLine:String = traceLines[traceBackLevel + 1];
            var startIndex:int = 0;
            var endIndex:int   = 0;
            startIndex = targetLine.indexOf('\.as:');
            endIndex   = targetLine.indexOf(']');
            return targetLine.substring(startIndex + 4, endIndex);
        }

        public function logClassName(obj:Object, traceLevel:int=2):void {
            var className:String = getQualifiedClassName(obj);
            log('[ClassName] ' + className, traceLevel);
        }

        public function dump(obj:Object):void {
            trace('');
            var printKeyAndValue:Function = function(key:String, value:*, depth:int):void {
                log(str.repeat('    ', depth) + key + ': ' + value, 4);
            };
            traverseSortedWithKey(obj, printKeyAndValue);
            trace('');
        }

        //------------------------------------------------------------
        // Asynchronous process utils
        //------------------------------------------------------------

        /**
         * See krewfw.utils.as3.KrewAsync.
         */
        public function async(asyncDef:*, onComplete:Function=null):void {
            var async:KrewAsync = new KrewAsync(asyncDef);
            async.go(onComplete);
        }

        //------------------------------------------------------------
        // Array utils
        //------------------------------------------------------------

        /**
         * Returns the last element of a list.
         * Passing optional n will return an array of the last n elements of the list.
         *
         * @param list Array or Vector is expected.
         */
        public function last(list:Object, n:int = -1):* {
            if (n == -1) {
                return list[list.length - 1];
            }
            return list.slice(-n);
        }

        /**
         * Returns shuffled copy of the list, using the Fisher-Yates shuffle algorithm.
         */
        public function shuffle(list:Array):Array {
            var shuffled:Array = [];

            var index:int = 0;
            for each (var val:* in list) {
                var randIndex:int = randInt(0, index);
                shuffled[index]     = shuffled[randIndex];
                shuffled[randIndex] = val;
                ++index;
            }

            return shuffled;
        }

        /**
         * <pre>
         *   range(5)           -> [0, 1, 2, 3, 4]
         *   range(3, 7)        -> [3, 4, 5, 6, 7]
         *   range(3, 3.1)      -> [3]
         *   range(2, 3.5, 0.5) -> [2.0, 2.5, 3.0, 3.5]
         *
         *   range(7, 3)        -> [7, 6, 5, 4, 3]
         *   range(7, 7)        -> [7]
         *   range(7, 6.9)      -> [7]
         *   range(3, 2, -0.5)  -> [3.0, 2.5, 2.0]
         *   range(7, 3, 1)     -> null  // invalid arguments
         *   range(0)           -> []
         * </pre>
         */
        public function range(first:Number, last:Number=NaN, step:Number=NaN):Array {
            // 1 argument
            if (isNaN(last)) {
                last  = first;
                first = 0;
            }

            // 2 arguments
            if (isNaN(step)) {
                step = (first < last) ? 1 : -1;
            }
            if (step == 0) { step = 1; }

            // 3 arguments
            if (!isNaN(step)  &&  first > last  &&  step > 0) {
                return null;
            }

            var iter:Number = first;
            var range:Array = [];
            if (first <= last) {
                while(iter < last) {
                    range.push(iter);  iter += step;
                }
            } else {
                while(iter > last) {
                    range.push(iter);  iter += step;
                }
            }
            return range;
        }

        //------------------------------------------------------------
        // Logic general utils
        //------------------------------------------------------------

        /**
         * Simply repeat func n times. Useful for making closures in loops.
         */
        public function times(count:int, func:Function):void {
            for (var i:int = 0;  i < count;  ++i) {
                func(i);
            }
        }

        /**
         * Select function randomly from weighted function list,
         * using Roulette Wheel Selection algorithm.
         *
         * @param candidates Array such as:
         * <pre>
         *     [
         *         {func: Function1, weight: 30},
         *         {func: Function2, weight: 70}
         *     ]
         * </pre>
         */
        public function selectFunc(candidates:Array):void {
            var totalWeight:Number = 0;
            var data:Object;
            for each (data in candidates) {
                totalWeight += data.weight;
            }

            var selectArea:Number = rand(totalWeight);
            var weightCountUp:Number = 0;
            for each (data in candidates) {
                weightCountUp += data.weight;
                if (weightCountUp >= selectArea) {
                    data.func();
                    return;
                }
            }
        }

        /**
         * Return value depending on threshold list.
         *
         * @param thresholds Array of Array such as:
         * <pre>
         *     [[threshold:int, value:int]], ...]
         * </pre>
         *
         * Example:
         *     If thresholds is [[100, 2], [200, 4], [300, 6]]
         *     and targetThreshold is 250,
         *     then this function returns 4 because 250 is larger than 200
         *     but smaller than 300.
         *
         */
        public function selectValue(targetThreshold:int, thresholds:Array):Number {
            var result:int = 0;
            for each (var data:Object in thresholds) {
                if (targetThreshold >= data[0]) {
                    result = data[1];
                }
            }
            return result;
        }

        //------------------------------------------------------------
        // Color utils
        //------------------------------------------------------------

        public function getAlpha(color:uint):int { return (color >> 24) & 0xff; }
        public function getRed  (color:uint):int { return (color >> 16) & 0xff; }
        public function getGreen(color:uint):int { return (color >>  8) & 0xff; }
        public function getBlue (color:uint):int { return  color        & 0xff; }

        /**
         * convert 24bit interger to RGB array (0xffffff -> [256, 256, 256])
         */
        public function int2rgb(color:uint):Array {
            return [getRed(color), getGreen(color), getBlue(color)];
        }

        public function rgb2int(red:int, green:int, blue:int):uint {
            return (red << 16) | (green << 8) | blue;
        }

        /**
         * convert HSV to 24bit interger
         *
         * @param hue （色相） [0, 360]
         * <pre>
         *     360, 0: red
         *         60: yellow
         *        120: green
         *        180: cyan
         *        240: blue
         *        300: magenta
         * </pre>
         *
         * @param saturation（彩度） [0, 1]
         *     0: 無彩色（グレースケール）
         *     1: 純色（最も鮮やか）
         *
         * @param val Value of Brightness （明度） [0, 1]
         *     0: 黒（最も暗い）
         *     1: 最も明るい（彩度が 0 なら白）
         */
        public function hsv2int(hue:Number, saturation:Number, val:Number):uint {
            hue %= 360;
            if (saturation <= 0) {
                return rgb2int(val, val, val);
            }

            var h:int = (hue / 60) % 6;
            var f:Number = (hue / 60) - h;
            var p:Number = val * (1 - saturation);
            var q:Number = val * (1 - (f * saturation));
            var t:Number = val * (1 - ((1 - f) * saturation));

            val *= 255;
            p   *= 255;
            q   *= 255;
            t   *= 255;

            switch (h) {
            case 0: return rgb2int(val, t, p);  break;
            case 1: return rgb2int(q, val, p);  break;
            case 2: return rgb2int(p, val, t);  break;
            case 3: return rgb2int(p, q, val);  break;
            case 4: return rgb2int(t, p, val);  break;
            case 5: return rgb2int(val, p, q);  break;
            }
            return 0xffffff;
        }

        public function hsv2intWithRand(hMin:Number, hMax:Number,
                                        sMin:Number, sMax:Number,
                                        vMin:Number, vMax:Number):uint {
            return hsv2int(
                randArea(hMin, hMax),
                randArea(sMin, sMax),
                randArea(vMin, vMax)
            );
        }

        //------------------------------------------------------------
        // Math utils
        //------------------------------------------------------------

        /**
         * Returns floating random number.
         *
         * <pre>
         *   rand(5)    -> 0.0 〜 5.0   // (max is not inclusive)
         *   rand(2, 4) -> 2.0 〜 4.0
         *   rand(4, 2) -> 2.0 〜 4.0
         * </pre>
         */
        public function rand(min:Number, max:Number=NaN):Number {
            if (isNaN(max)) {
                max = min;
                min = 0;
            }
            return min + (Math.random() * (max - min));
        }

        /**
         * Returns integer random number.
         *
         * <pre>
         *   rand(5)    -> any of  0, 1, 2, 3, 4
         *   rand(0, 5) -> any of  0, 1, 2, 3, 4, 5   // (5 is inclusive)
         *   rand(5, 0) -> any of  0, 1, 2, 3, 4, 5
         *   rand(-5)   -> any of  -1, -2, -3, -4, -5
         * </pre>
         */
        public function randInt(min:Number, max:Number=NaN):int {
            if (!isNaN(max)) {
                if (min < max) { ++max; }
                if (min > max) { ++min; }
            }
            return Math.floor(rand(min, max));
        }

        /** OLD CODE. Now this is alias of rand(min, max) */
        public function randArea(min:Number, max:Number):Number {
            return rand(min, max);
        }

        public function randPlusOrMinus(min:Number, max:Number):Number {
            var val:Number = rand(min, max);
            if (rand(100) < 50) { val = -val; }
            return val;
        }

        public function randIntSeeded(seed:uint, min:int=0, max:int=int.MAX_VALUE):int {
            if (min > max) {
                var tmp:int = min;
                min = max;
                max = tmp;
            }

            var val:uint = KrewRandom.getUintWithSeed(seed);
            return min + (val % (max - min + 1));
        }

        public function rad2deg(rad:Number):Number {
            return rad / Math.PI * 180.0;
        }

        public function deg2rad(deg:Number):Number {
            return deg / 180.0 * Math.PI;
        }

        public function within(value:Number, min:Number, max:Number):Number {
            if (value < min) { return min; }
            if (value > max) { return max; }
            return value;
        }

        // ToDo: 可変長引数で書きなおす
        public function min(a:Number, b:Number):Number {
            return (a < b) ? a : b;
        }

        // ToDo: 可変長引数で書きなおす
        public function max(a:Number, b:Number):Number {
            return (a > b) ? a : b;
        }

        public function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
            return Math.sqrt(squaredDistance(x1, y1, x2, y2));
        }

        public function squaredDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
            var dx:Number = (x2 - x1);
            var dy:Number = (y2 - y1);
            return (dx * dx) + (dy * dy);
        }

        //------------------------------------------------------------
        // Date utils
        //------------------------------------------------------------

        /**
         * If today is 2014-07-08, returns int value 20140708.
         */
        public function dateVal():uint {
            var date:Date = new Date();
            return   (date.fullYear * 10000)
                  + ((date.month + 1) * 100)
                  +   date.date;
        }

        //------------------------------------------------------------
        // Data structure general utils
        //------------------------------------------------------------

        /**
         * Traverse Object and apply function for each key-values.
         * @param callback Function that accepts (key:String, value:*, depth:int) as its parameter.
         */
        public function traverse(obj:Object, callback:Function, depth:int=0):void {
            for (var key:String in obj) {
                var value:* = obj[key];
                callback(key, value, depth);
                if (typeof value == 'object') {
                    traverse(value, callback, depth + 1);
                }
            }
        }

        public function traverseSortedWithKey(obj:Object, callback:Function, depth:int=0):void {
            var keys:Array = [];
            var key:String;
            for (key in obj) { keys.push(key); }
            keys.sort();

            for each (key in keys) {
                var value:* = obj[key];
                callback(key, value, depth);
                if (typeof value == 'object') {
                    traverseSortedWithKey(value, callback, depth + 1);
                }
            }
        }

        /**
         * Traverse Object and apply function for each key-values.
         * The callback accepts absolute path to target key joined by dot.
         * For example, given the following object:
         * <pre>
         *     {
         *         hoge: {
         *             fuga: {
         *                 piyo: 123
         *             }
         *         }
         *     }
         * </pre>
         * then callback of 'piyo: 123' key-value accepts ('piyo', 123, 'hoge.fuga.piyo')
         * as its parameter.
         *
         * @param callback Function that accepts (key:String, value:*, path:String) as its parameter.
         */
        public function traverseWithAbsPath(obj:Object, callback:Function, path:String=''):void {
            for (var key:String in obj) {
                var value:* = obj[key];
                if (getQualifiedClassName(value) == 'Object'  &&  value != null) {
                    traverseWithAbsPath(value, callback, path + key + '.');
                } else {
                    callback(key, value, path + key);
                }
            }
        }

        /**
         * Convert nested object into new flat object.
         * For example, following object:
         * <pre>
         *     {
         *         hoge: 123,
         *         fuga: {
         *             piyo: 456
         *         }
         *     }
         * </pre>
         * is converted into object as below:
         * <pre>
         *     {
         *         'hoge'     : 123,
         *         'fuga.piyo': 456
         *     }
         * </pre>
         * This method is non-destructive.
         */
        public function flattenObject(obj:Object):Object {
            var flattenedObj:Object = new Object();
            var addToFlatObj:Function = function(key:String, value:*, path:String):void {
                flattenedObj[path] = value;
            };
            traverseWithAbsPath(obj, addToFlatObj);
            return flattenedObj;
        }

    }
}
