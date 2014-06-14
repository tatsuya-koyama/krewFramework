package krewfw.core_internal {

    import starling.animation.Transitions;
    import starling.animation.Tween;
    import starling.display.DisplayObject;

    import krewfw.core.KrewActor;
    import krewfw.utils.krew;
    import krewfw.utils.as3.KrewObjectPool;
    import krewfw.utils.as3.KrewPoolable;

    /**
     * StuntAction means Actor's Tween Animation.
     */
    //------------------------------------------------------------
    public class StuntAction implements KrewPoolable {

        private static var _objectPool:KrewObjectPool = new KrewObjectPool(StuntAction, 1024);

        private var _duration:Number = 0;
        private var _progress:Number = 0;

        public var actor:KrewActor;
        public var nextAction:StuntAction;
        public var updater:Function = null;      // function(action:StuntAction):void
        public var foreverMode:Boolean = false;  // これが true の間は Action を終わりにせず update を続ける

        private var _passedTime:Number = 0;
        private var _frame:int = 0;

        private static const ENCHANT_NONE     :int = 0;
        private static const ENCHANT_MOVE     :int = 1;
        private static const ENCHANT_MOVE_TO  :int = 2;
        private static const ENCHANT_SCALE    :int = 3;
        private static const ENCHANT_SCALE_TO :int = 4;
        private static const ENCHANT_ALPHA_TO :int = 5;
        private static const ENCHANT_ROTATE   :int = 6;
        private static const ENCHANT_ROTATE_TO:int = 7;
        private static const ENCHANT_KILL     :int = 8;
        private var _enchantType:int = 0;
        private var _transition:String;
        private var _value1:Number;
        private var _value2:Number;

        //------------------------------------------------------------
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
        // implementation of KrewPoolable
        //------------------------------------------------------------

        public function onPooledObjectCreate(params:Object):void {}

        public function onPooledObjectInit(params:Object):void {
            _duration = params.duration;

            _progress   = 0;
            nextAction  = null;
            updater     = null;
            foreverMode = false;
            _passedTime = 0;
            _frame      = 0;

            _enchantType = ENCHANT_NONE;
        }

        public function onRetrieveFromPool(params:Object):void {}

        public function onPooledObjectRecycle():void {}

        public function onDisposeFromPool():void {}

        //------------------------------------------------------------
        // pooling interface
        //------------------------------------------------------------

        public static function getObject(duration:Number=0):StuntAction {
            var params:Object = {duration: duration};
            return _objectPool.getObject(params) as StuntAction;
        }

        public function recycle():void {
            _objectPool.recycle(this);
        }

        //------------------------------------------------------------
        public function StuntAction() {}

        public function and(action:StuntAction):StuntAction {
            nextAction = action;
            action.actor = this.actor;
            return action;
        }

        public function update(passedTime:Number):void {
            ++_frame;
            _progress += passedTime;
            _passedTime = passedTime;

            if (_frame == 1) { _enchant(); }

            if (updater != null) {
                updater(this);
            }
        }

        /**
         * Actor が layer に乗った後、初回フレームに Tween の登録や
         * ショートカット処理の実行を行う。
         * 以前は move や kill のメソッドの中で Function を登録する形にしていたが、
         * クロージャを作るのが意外とメモリを食ったので、GC を避けるためにこのやり方にした
         */
        private function _enchant():void {
            if (_enchantType == ENCHANT_NONE) { return; }

            switch (_enchantType) {
            case ENCHANT_MOVE:
                var tween:Tween = actor.enchant(_duration, _transition);
                tween.animate('x', actor.x + _value1);
                tween.animate('y', actor.y + _value2);
                break;

            case ENCHANT_MOVE_TO:
                actor.enchant(_duration, _transition).moveTo(_value1, _value2);
                break;

            case ENCHANT_SCALE_TO:
                var tween:Tween = actor.enchant(_duration, _transition);
                tween.animate('scaleX', _value1);
                tween.animate('scaleY', _value2);
                break;

            case ENCHANT_ALPHA_TO:
                actor.enchant(_duration, _transition).fadeTo(_value1);
                break;

            case ENCHANT_ROTATE:
                actor.enchant(_duration, _transition)
                    .animate("rotation", actor.rotation + krew.deg2rad(_value1));
                break;

            case ENCHANT_ROTATE_TO:
                actor.enchant(_duration, _transition)
                    .animate("rotation", krew.deg2rad(_value1));
                break;

            case ENCHANT_KILL:
                if (actor) { actor.passAway(); }
                break;
            }
        }

        public function isFinished():Boolean {
            if (foreverMode) { return false; }

            return (_progress >= _duration);
        }

        //------------------------------------------------------------
        // Shortcuts
        //------------------------------------------------------------
        public function wait(duration:Number):StuntAction {
            var action:StuntAction = StuntAction.getObject(duration);
            return this.and(action);
        }

        /** １回だけ実行して、duration 秒待つ。コールバックの引数には StuntAction を渡す */
        public function doit(duration:Number, anUpdater:Function):StuntAction {
            var action:StuntAction = StuntAction.getObject(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                anUpdater(_action);
            };
            return this.and(action);
        }

        /**
         * １回だけ実行して、即座に次に行く。引数に何も渡さない.
         * ToDo: AS3 のコールバックの引数の型の扱いよくわかってない
         */
        public function justdoit(duration:Number, anUpdater:Function):StuntAction {
            var action:StuntAction = StuntAction.getObject(duration);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                anUpdater();
            };
            return this.and(action);
        }

        /** 関数を duration 秒間、実行し続ける */
        public function goon(duration:Number, anUpdater:Function):StuntAction {
            var action:StuntAction = StuntAction.getObject(duration);
            action.updater = function(_action:StuntAction):void {
                anUpdater(_action);
            };
            return this.and(action);
        }

        /**
         * anUpdater を、それが true を返すまで実行し続ける
         * @param anUpdater schema: function(passedTime:Number):Boolean
         */
        public function until(anUpdater:Function):StuntAction {
            var action:StuntAction = StuntAction.getObject(0);
            action.foreverMode = true;

            action.updater = function(_action:StuntAction):void {
                var isTimeToEnd:Boolean = anUpdater(_action.passedTime);
                if (isTimeToEnd) { _action.foreverMode = false; }
            };
            return this.and(action);
        }

        //------------------------------------------------------------
        // move tween
        //------------------------------------------------------------
        public function move(duration:Number, dx:Number, dy:Number,
                             transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_MOVE;
            action._transition  = transition;
            action._value1      = dx;
            action._value2      = dy;
            return this.and(action);
        }

        public function moveEaseIn(duration:Number, dx:Number, dy:Number):StuntAction {
            return move(duration, dx, dy, Transitions.EASE_IN);
        }

        public function moveEaseOut(duration:Number, dx:Number, dy:Number):StuntAction {
            return move(duration, dx, dy, Transitions.EASE_OUT);
        }

        public function moveTo(duration:Number, x:Number, y:Number,
                               transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_MOVE_TO;
            action._transition  = transition;
            action._value1      = x;
            action._value2      = y;
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
                                transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_SCALE_TO;
            action._transition  = transition;
            action._value1      = scaleX;
            action._value2      = scaleY;
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
                                transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_ALPHA_TO;
            action._transition  = transition;
            action._value1      = alpha;
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
                               transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_ROTATE;
            action._transition  = transition;
            action._value1      = rotation;
            return this.and(action);
        }

        public function rotateEaseIn(duration:Number, rotation:Number):StuntAction {
            return rotate(duration, rotation, Transitions.EASE_IN);
        }

        public function rotateEaseOut(duration:Number, rotation:Number):StuntAction {
            return rotate(duration, rotation, Transitions.EASE_OUT);
        }

        public function rotateTo(duration:Number, rotation:Number,
                                 transition:String=Transitions.LINEAR):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);
            action._enchantType = ENCHANT_ROTATE_TO;
            action._transition  = transition;
            action._value1      = rotation;
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
            var action:StuntAction = StuntAction.getObject(0);
            action._enchantType = ENCHANT_KILL;
            return this.and(action);
        }

        /**
         * KrewActor.sendMessage のショートカット。
         * KrewActor 以外に使うと何も起こらない
         */
        public function send(eventType:String, eventArgs:Object=null):StuntAction {
            var action:StuntAction = StuntAction.getObject(0);
            action.updater = function(_action:StuntAction):void {
                if (_action.frame > 1) { return; }
                var actor:KrewActor = _action.actor;
                if (actor) {
                    actor.sendMessage(eventType, eventArgs);
                }
            };
            return this.and(action);
        }

        /** １回暗くなって明るくなる */
        public function blink(displayObj:DisplayObject,
                              duration:Number=0.25, alphaMin:Number=0.3):StuntAction
        {
            var action:StuntAction = StuntAction.getObject(duration);

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
