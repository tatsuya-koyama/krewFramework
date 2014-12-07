package krewdemo.actor.performance_test {

    import flash.utils.getTimer;

    import starling.events.Event;

    import krewfw.core.KrewActor;

    import krewdemo.actor.ui.ConsoleBox;
    import krewdemo.actor.ui.TextButton;

    //------------------------------------------------------------
    public class ArraySpliceTester extends KrewActor {

        private static const NUM_ELEMENTS:int = 5000;

        private var _console:ConsoleBox;

        //------------------------------------------------------------
        public override function init():void {
            touchable = true;

            _console = new ConsoleBox(210, 30, 250, 230, 5, 9);
            addActor(_console);

            var button1:TextButton = new TextButton(100, 100, "Array.splice()");
            addActor(button1);
            button1.setOnPress(_spliceArrayWithBuiltInMethod);

            var button2:TextButton = new TextButton(100, 160, "Manually shift");
            addActor(button2);
            button2.setOnPress(_spliceArrayWithManuallyShift);

            var clearButton:TextButton = new TextButton(285, 280, "Clear console");
            addActor(clearButton);
            clearButton.setOnPress(_clearConsole)
        }

        private function _spliceArrayWithBuiltInMethod(event:Event):void {
            touchable = false;
            _console.appendText("Start splice with built-in method...\n");
            _console.appendText("(" + (NUM_ELEMENTS / 2) + " calls)\n");
            _console.toBottom();

            delayedFrame(function():void {
                var array:Array = _makeArraySample();

                var startTime:int = getTimer();
                var count:int = 0;
                for (var i:int = 0;  i < array.length;  ++i) {
                    ++count;
                    if (array[i] % 2 == 0) {
                        array.splice(i, 1);
                        --i;
                    }
                }
                var endTime:int = getTimer();

                var processTime:int = endTime - startTime;
                _console.appendText("Done. Process time: "
                                    + "<font color='#ffaa55'>" + processTime + "</font>"
                                    + " [mSec]\n\n");
                _console.toBottom();
                touchable = true;
            }, 2);
        }

        private function _spliceArrayWithManuallyShift(event:Event):void {
            touchable = false;
            _console.appendText("Start splice with manually shift...\n");
            _console.appendText("(" + (NUM_ELEMENTS / 2) + " calls)\n");
            _console.toBottom();

            delayedFrame(function():void {
                var array:Array = _makeArraySample();

                var startTime:int = getTimer();
                var count:int = 0;
                for (var i:int = 0;  i < array.length;  ++i) {
                    ++count;
                    if (array[i] % 2 == 0) {
                        _manuallyRemove(array, i);
                        //_orderDestructiveRemove(array, i);
                        --i;
                    }
                }
                var endTime:int = getTimer();

                var processTime:int = endTime - startTime;
                _console.appendText("Done. Process time: "
                                    + "<font color='#ffaa55'>" + processTime + "</font>"
                                    + " [mSec]\n\n");
                _console.toBottom();
                touchable = true;
            }, 2);
        }

        private function _manuallyRemove(list:Array, index:int):void {
            for (var i:int = index + 1;  i < list.length;  ++i) {
                list[i - 1] = list[i];
            }
            list.length = list.length - 1;
        }

        private function _orderDestructiveRemove(list:Array, index:int):void {
            list[index] = list[list.length - 1];
            list.length = list.length - 1;
        }

        private function _clearConsole(event:Event):void {
            _console.clear();
        }

        private function _makeArraySample():Array {
            var array:Array = [];
            for (var i:int = 0;  i < NUM_ELEMENTS;  ++i) {
                array.push(i);
            }
            return array;
        }

    }
}
