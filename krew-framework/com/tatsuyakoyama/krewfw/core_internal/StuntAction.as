package com.tatsuyakoyama.krewfw.core_internal {

    import starling.display.DisplayObject;
    import starling.animation.Tween;
    import starling.animation.Transitions;

    import com.tatsuyakoyama.krewfw.utility.KrewUtil;
    import com.tatsuyakoyama.krewfw.core.KrewActor;

    /**
     * StuntAction means Actor's Tween Animation.
     */
    //------------------------------------------------------------
    public class StuntAction {

        private var _duration:Number = 0;
        private var _progress:Number = 0;

        public var instructor:StuntActionInstructor;
        public var nextAction:StuntAction;
        public var updater:Function = function():void {};

        private var _passedTime:Number = 0;
        private var _frame:int = 0;

        //------------------------------------------------------------
        public function get actor():KrewActor {
            return instructor.actor;
        }

        public function get duration():Number {
            return _duration;
        }

        public function get progress():Number {
            return _progress;
        }

        public function get passedTime():Number {
            return _passedTime;
        }

        public function get frame():int {
            return _frame;
        }

        //------------------------------------------------------------
        public function StuntAction(duration:Number=0) {
            _duration = duration;
        }

        public function and(action:StuntAction):StuntAction {
            nextAction = action;
            action.instructor = this.instructor;
            return action;
        }

        public function update(passedTime:Number):void {
            ++_frame;
            _progress += passedTime;
            _passedTime = passedTime;
            updater(this);
        }

        public function isFinished():Boolean {
            return (_progress >= _duration);
        }

        //------------------------------------------------------------
        // Shortcuts
        //------------------------------------------------------------
        public function wait(duration:Number):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            return this.and(action);
        }

        /** １回だけ実行して、duration 秒待つ。コールバックの引数には StuntAction を渡す */
        public function doit(duration:Number, aUpdater:Function):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                aUpdater(_action);
            }
            return this.and(action);
        }

        /**
         * １回だけ実行して、duration 秒待つ。引数に何も渡さない.
         * ToDo: AS3 のコールバックの引数の型の扱いよくわかってない
         */
        public function justdoit(duration:Number, aUpdater:Function):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                aUpdater();
            }
            return this.and(action);
        }

        /** 関数を duration 秒間、実行し続ける */
        public function goon(duration:Number, aUpdater:Function):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                aUpdater(_action);
            }
            return this.and(action);
        }

        //------------------------------------------------------------
        // move tween
        //------------------------------------------------------------
        public function move(duration:Number, dx:Number, dy:Number,
                             transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                var tween:Tween = _action.actor.enchant(duration, transition);
                tween.animate('x', _action.actor.x + dx);
                tween.animate('y', _action.actor.y + dy);
            };
            return this.and(action);
        }

        public function moveEaseIn(duration:Number, dx:Number, dy:Number):StuntAction {
            return move(duration, dx, dy, Transitions.EASE_IN);
        }

        public function moveEaseOut(duration:Number, dx:Number, dy:Number):StuntAction {
            return move(duration, dx, dy, Transitions.EASE_OUT);
        }

        public function moveTo(duration:Number, x:Number, y:Number,
                               transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                _action.actor.enchant(duration, transition).moveTo(x, y);
            };
            return this.and(action);
        }

        public function moveToEaseIn(duration:Number, x:Number, y:Number):StuntAction {
            return moveTo(duration, x, y, Transitions.EASE_IN);
        }

        public function moveToEaseOut(duration:Number, x:Number, y:Number):StuntAction {
            return moveTo(duration, x, y, Transitions.EASE_OUT);
        }

        //------------------------------------------------------------
        // scale tween
        //------------------------------------------------------------
        public function scaleTo(duration:Number, scaleX:Number, scaleY:Number,
                               transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                var tween:Tween = _action.actor.enchant(duration, transition);
                tween.animate('scaleX', scaleX);
                tween.animate('scaleY', scaleY);
            };
            return this.and(action);
        }

        public function scaleToEaseIn(duration:Number, scaleX:Number, scaleY:Number):StuntAction {
            return scaleTo(duration, scaleX, scaleY, Transitions.EASE_IN);
        }

        public function scaleToEaseOut(duration:Number, scaleX:Number, scaleY:Number):StuntAction {
            return scaleTo(duration, scaleX, scaleY, Transitions.EASE_OUT);
        }

        //------------------------------------------------------------
        // alpha tween
        //------------------------------------------------------------
        public function alphaTo(duration:Number, alpha:Number,
                                transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                _action.actor.enchant(duration, transition).fadeTo(alpha);
            };
            return this.and(action);
        }

        public function alphaToEaseIn(duration:Number, alpha:Number):StuntAction {
            return alphaTo(duration, alpha, Transitions.EASE_IN);
        }

        public function alphaToEaseOut(duration:Number, alpha:Number):StuntAction {
            return alphaTo(duration, alpha, Transitions.EASE_OUT);
        }

        //------------------------------------------------------------
        // rotate tween
        //------------------------------------------------------------
        public function rotate(duration:Number, rotation:Number,
                               transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                _action.actor.enchant(duration, transition)
                    .animate("rotation", _action.actor.rotation + KrewUtil.deg2rad(rotation));
            };
            return this.and(action);
        }

        public function rotateEaseIn(duration:Number, rotation:Number):StuntAction {
            return rotate(duration, rotation, Transitions.EASE_IN);
        }

        public function rotateEaseOut(duration:Number, rotation:Number):StuntAction {
            return rotate(duration, rotation, Transitions.EASE_OUT);
        }

        public function rotateTo(duration:Number, rotation:Number,
                                 transition:String=Transitions.LINEAR):StuntAction {
            var action:StuntAction = new StuntAction(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                _action.actor.enchant(duration, transition)
                    .animate("rotation", KrewUtil.deg2rad(rotation));
            };
            return this.and(action);
        }

        public function rotateToEaseIn(duration:Number, rotation:Number):StuntAction {
            return rotateTo(duration, rotation, Transitions.EASE_IN);
        }

        public function rotateToEaseOut(duration:Number, rotation:Number):StuntAction {
            return rotateTo(duration, rotation, Transitions.EASE_OUT);
        }

        //------------------------------------------------------------
        /**
         * KrewActor を殺すためのショートカット。
         * KrewActor 以外に使うと何も起こらない
         */
        public function kill():StuntAction {
            var action:StuntAction = new StuntAction(0);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                var actor:KrewActor = _action.instructor.actor as KrewActor;
                if (actor) {
                    actor.passAway();
                }
            };
            return this.and(action);
        }

        /** １回暗くなって明るくなる */
        public function blink(displayObj:DisplayObject,
                              duration:Number=0.25, alphaMin:Number=0.3):StuntAction {
            var action:StuntAction = new StuntAction(duration);

            action.updater = function(_action:StuntAction):void {
                var halfTime:Number = _action.duration / 2;
                if (_action.progress < halfTime) {
                    // fade out
                    var progress:Number = _action.progress / halfTime;
                    displayObj.alpha = 1 - (progress * (1 - alphaMin));
                } else {
                    // fade in
                    var invProgress:Number = (_action.duration - _action.progress) / halfTime;
                    displayObj.alpha = 1 - (invProgress * (1 - alphaMin));
                }
            };
            return this.and(action);
        }
    }
}
