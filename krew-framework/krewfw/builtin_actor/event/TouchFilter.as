package krewfw.builtin_actor.event {

    import flash.geom.Point;

    import starling.display.Quad;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import krewfw.KrewConfig;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewSystemEventType;

    //------------------------------------------------------------
    public class TouchFilter extends KrewActor {

        private var _quad:Quad;

        //------------------------------------------------------------
        public function TouchFilter(left:Number=0, top:Number=0,
                                    filterWidth:Number=NaN, filterHeight:Number=NaN)
        {
            touchable = true;

            if (isNaN(filterWidth )) { filterWidth  = KrewConfig.SCREEN_WIDTH;  }
            if (isNaN(filterHeight)) { filterHeight = KrewConfig.SCREEN_HEIGHT; }
            _quad   = new Quad(filterWidth, filterHeight);
            _quad.x = left;
            _quad.y = top;
            _quad.touchable = true;
            _quad.alpha     = 0;
            addChild(_quad);

            addEventListener(TouchEvent.TOUCH, _onTouch);
        }

        public override function init():void {

        }

        private function _onTouch(event:TouchEvent):void {
            var localPos:Point;

            var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if (touchBegan) {
                localPos = touchBegan.getLocation(this);
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_ANYWAY, {x: localPos.x, y: localPos.y});
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_BEGAN, {
                    x: localPos.x, y: localPos.y, touchEvent: event, touchObj: touchBegan
                });
            }

            var touchMoved:Touch = event.getTouch(this, TouchPhase.MOVED);
            if (touchMoved) {
                localPos = touchMoved.getLocation(this);
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_ANYWAY, {x: localPos.x, y: localPos.y});
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_MOVED, {
                    x: localPos.x, y: localPos.y, touchEvent: event, touchObj: touchMoved
                });
            }

            var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
            if (touchEnded) {
                localPos = touchEnded.getLocation(this);
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_ANYWAY, {x: localPos.x, y: localPos.y});
                sendMessage(KrewSystemEventType.SCREEN_TOUCH_ENDED, {
                    x: localPos.x, y: localPos.y, touchEvent: event, touchObj: touchEnded
                });
            }
        }

    }
}
