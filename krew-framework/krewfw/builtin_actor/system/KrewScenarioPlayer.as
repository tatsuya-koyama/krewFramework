package krewfw.builtin_actor.system {

    import krewfw.core.KrewActor;

    /**
     * Base class for event-driven command player.
     */
    //------------------------------------------------------------
    public class KrewScenarioPlayer extends KrewActor {

        private var _eventList:Array;
        private var _eventsByTrigger:Object;

        private var _triggers:Object = {};
        private var _methods:Object  = {};

        //------------------------------------------------------------
        public function KrewScenarioPlayer() {
            displayable = false;
        }

        protected override function onDispose():void {
            _eventList       = null;
            _eventsByTrigger = null;
            _triggers        = null;
            _methods         = null;
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        /**
         * @params eventList Example:
         * <pre>
         * [
         *     {
         *         "trigger_key" : "start_turn",
         *         "trigger_params": {"turn": 1},
         *         "method": "dialog",
         *         "params": {
         *             "messages": [ ... ]
         *         },
         *         "next": [
         *             {
         *                 "method": "overlay",
         *                 "params": { ... }
         *             }
         *         ]
         *     },
         *     ...
         * ]
         * </pre>
         */
        public function setData(eventList:Array):void {
            _eventList = eventList;

            _eventsByTrigger = {};
            for each (var eventData:Object in _eventList) {
                var triggerKey:String = eventData.trigger_key;
                if (!triggerKey) { continue; }

                if (!_eventsByTrigger[triggerKey]) {
                    _eventsByTrigger[triggerKey] = [];
                }
                _eventsByTrigger[triggerKey].push(eventData);
            }
        }

        /**
         * @param checker Schema: function(eventArgs;Object, triggerParams:Object):Boolean
         */
        public function addTrigger(triggerKey:String, eventName:String, checker:Function):void {
            _triggers[triggerKey] = new TriggerInfo(eventName, checker);
        }

        /**
         * @param triggerInfoList Example:
         * <pre>
         * [
         *     ["triggerKey", "eventName", checkerFunc],
         *     ...
         * ]
         * </pre>
         */
        public function addTriggers(triggerInfoList:Array):void {
            for each (var info:Array in triggerInfoList) {
                addTrigger(info[0], info[1], info[2]);
            }
        }

        /**
         * @param handler Schema: function(params:Object, onComplete:Function):void
         */
        public function addMethod(methodName:String, handler:Function):void {
            _methods[methodName] = handler;
        }

        /**
         * @param triggerInfoList Example:
         * <pre>
         * [
         *     ["methodName", methodFunc],
         *     ...
         * ]
         * </pre>
         */
        public function addMethods(methodList:Array):void {
            for each (var info:Array in methodList) {
                addMethod(info[0], info[1]);
            }
        }

        /**
         * Activate player.
         * Please call this after setData(), addTriggers(), addMethods(), and init().
         */
        public function activate():void {
            for (var triggerKey:String in _eventsByTrigger) {
                _listenEvent(triggerKey);
            }
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _listenEvent(triggerKey:String):void {
            var info:TriggerInfo = _triggers[triggerKey];
            if (!info) {
                throw new Error('[KrewEventPlayer] trigger not registered: ' + triggerKey);
                return;
            }

            listen(info.eventName, function(eventArgs:Object):void {
                for each (var eventData:Object in _eventsByTrigger[triggerKey]) {

                    var triggerParams:Object = eventData.trigger_params;
                    if (!info.checker(eventArgs, triggerParams)) { continue; }

                    _callMethod(eventData);
                }
            });
        }

        private function _callMethod(eventData:Object):void {
            var methodName:String = eventData.method;
            if (!methodName) {
                throw new Error('[KrewEventPlayer] method name not found. (trigger: '
                                + eventData.trigger_key + ')');
                return;
            }

            var method:Function = _methods[methodName];
            if (method == null) {
                throw new Error('[KrewEventPlayer] method not registered: ' + methodName);
                return;
            }

            method(eventData.params, function():void {
                _callNextMethod(eventData);
            });
        }

        private function _callNextMethod(parentEventData:Object):void {
            if (!parentEventData.next) { return; }

            for each (var nextEventData:Object in parentEventData.next) {
                _callMethod(nextEventData);
            }
        }

    }
}


class TriggerInfo {

    public var eventName:String;
    public var checker:Function;

    public function TriggerInfo(eventName:String, checker:Function) {
        this.eventName = eventName;
        this.checker   = checker;
    }

}
