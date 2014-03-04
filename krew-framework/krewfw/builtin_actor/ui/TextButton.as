package krewfw.builtin_actor.ui {

    import starling.text.TextField;
    import starling.events.Touch;
    import starling.events.TouchEvent;
    import starling.events.TouchPhase;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class TextButton extends KrewActor {

        private var _text:TextField;
        private var _onTouchEnd:Function;
        private var _autoTouchDisable:Boolean;

        //------------------------------------------------------------
        public function get text():TextField {
            return _text;
        }

        //------------------------------------------------------------
        public function TextButton(text:TextField, onTouchEnd:Function,
                                   autoTouchDisable:Boolean=true)
        {
            touchable = true;

            _text = text;
            addText(_text);

            _onTouchEnd = onTouchEnd;
            _autoTouchDisable = autoTouchDisable;
            _text.addEventListener(TouchEvent.TOUCH, _onTouch);
        }

        private function _onTouch(event:TouchEvent):void {
            // ToDo: 外で指を離したときには作動させない
            var touchEnded:Touch = event.getTouch(this, TouchPhase.ENDED);
            if (touchEnded) {
                if (_autoTouchDisable) { touchable = false; }
                _onTouchEnd();
            }
        }
    }
}
