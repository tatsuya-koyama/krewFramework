package com.tatsuyakoyama.krewfw.builtin_actor {

    import flash.geom.Point;

    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import com.tatsuyakoyama.krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class DraggableActor extends KrewActor {

        //------------------------------------------------------------
        public function DraggableActor() {
            touchable = true;

            addEventListener(TouchEvent.TOUCH, _onTouch);
        }

        private function _onTouch(event:TouchEvent):void {
            var touchBegan:Touch = event.getTouch(this, TouchPhase.BEGAN);
            if (touchBegan) {
                onTouchBegan(event);
            }

            var touchMoved:Touch = event.getTouch(this, TouchPhase.MOVED);
            if (touchMoved) {
                var delta:Point = touchMoved.getMovement(parent);
                x += delta.x;
                y += delta.y;

                onTouchMoved(event);
            }

            var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
            if (touchEnded) {
                onTouchEnded(event);
            }
        }

        //------------------------------------------------------------
        // Override as you like
        //------------------------------------------------------------
        protected function onTouchBegan(event:TouchEvent):void {}
        protected function onTouchMoved(event:TouchEvent):void {}
        protected function onTouchEnded(event:TouchEvent):void {}
    }
}
