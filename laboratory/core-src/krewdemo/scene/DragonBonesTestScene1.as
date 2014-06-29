package krewdemo.scene {

    import flash.events.Event;
    import flash.ui.Keyboard;

    import starling.display.Sprite;
    import starling.text.TextField;

    import dragonBones.Armature;
    import dragonBones.animation.WorldClock;
    import dragonBones.factorys.StarlingFactory;

    import krewfw.core.KrewBlendMode;
    import krewfw.core.KrewScene;
    import krewfw.builtin_actor.display.ScreenCurtain;
    import krewfw.builtin_actor.display.SimpleLoadingScreen;
    import krewfw.builtin_actor.ui.KeyboardStatus;
    import krewfw.utils.starling.TextFactory;

    import krewdemo.GameEvent;
    import krewdemo.actor.common.ScreenFilter;
    import krewdemo.actor.feature_test.*;
    import krewdemo.actor.title.TileEffect;

    //------------------------------------------------------------
    public class DragonBonesTestScene1 extends FeatureTestSceneBase {

        private var _factory:StarlingFactory;
        private var _armature:Armature;
        private var _armatureSprite:Sprite;

        private var _key:KeyboardStatus;
        private var _currentAnimation:String;

        //------------------------------------------------------------
        public override function getRequiredAssets():Array {
            return [
                "animation/db_robot.dbpng"
            ];
        }

        protected override function onDispose():void {
            if (_factory) {
                _factory.dispose();
            }
            if (_armature) {
                _armature.dispose();
            }
        }

        public override function hookBeforeInit(onComplete:Function):void {
            onComplete();
        }

        public override function initAfterLoad():void {
            _bgColor = 0x999777;
            super.initAfterLoad();

            _key = new KeyboardStatus();
            setUpActor('l-ui', _key);

            setUpActor('l-ui', new InfoPopUp(
                  "- Bone animation test.\n"
                + "- Powered by DragonBones with XML-marged PNG file.\n"
            ));

            getLayer("l-front").addText(_makeText(
                  ">: Move right\n"
                + "<: Move left\n"
                + "^: Look up\n"
            ));

            _initDragonBones();
        }

        private function _makeText(str:String="", fontName:String="tk_courier"):TextField {
            var text:TextField = TextFactory.makeText(
                300, 90, str, 14, fontName, 0xffffff - 0x666622,
                15, 35, "left", "top", false
            );
            text.blendMode = KrewBlendMode.SUB;
            return text;
        }

        private function _initDragonBones():void {
            _factory = new StarlingFactory();
            _factory.addEventListener(Event.COMPLETE, _onDBLoadComplete);
            _factory.parseData(getByteArray("db_robot"));
        }

        private function _onDBLoadComplete(event:Event):void {
            _armature = _factory.buildArmature("Robot");

            _armatureSprite = _armature.display as Sprite;
            _armatureSprite.x = 240;
            _armatureSprite.y = 180;
            _armatureSprite.scaleX = 0.5;
            _armatureSprite.scaleY = 0.5;
            getLayer("l-front").addChild(_armatureSprite);

            _setAnimation("stand");
        }

        private function _setAnimation(tag:String):void {
            if (_currentAnimation == tag) { return; }

            _armature.animation.gotoAndPlay(tag);
            _currentAnimation = tag;
        }

        public override function onUpdate(passedTime:Number):void {
            if (!_armature) { return; }

            _armature.advanceTime(passedTime);

            if (_key.isPressed(Keyboard.UP)) {
                _setAnimation("look_up");
            }
            else if (_key.isPressed(Keyboard.RIGHT)) {
                _armatureSprite.x += 80 * passedTime;
                _armatureSprite.scaleX = 0.5;
                _setAnimation("walk");
            }
            else if (_key.isPressed(Keyboard.LEFT)) {
                _armatureSprite.x -= 80 * passedTime;
                _armatureSprite.scaleX = -0.5;
                _setAnimation("walk");
            }
            else {
                _setAnimation("stand");
            }
        }

    }
}
