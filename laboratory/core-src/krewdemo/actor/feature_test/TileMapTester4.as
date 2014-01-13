package krewdemo.actor.feature_test {

    import nape.callbacks.CbEvent;
    import nape.callbacks.CbType;
    import nape.callbacks.InteractionCallback;
    import nape.callbacks.InteractionListener;
    import nape.callbacks.InteractionType;
    import nape.phys.Body;

    import krewfw.builtin_actor.ui.ImageButton;

    import krewdemo.GameEvent;

    //------------------------------------------------------------
    public class TileMapTester4 extends TileMapTester3 {

        private var _interactionListener:InteractionListener;
        private var _wallCbType:CbType = new CbType();
        private var _heroCbType:CbType = new CbType();

        private var _jumpLife:int = 2;

        //------------------------------------------------------------
        public function TileMapTester4():void {
            _gravity = 1000;

            _interactionListener = new InteractionListener(
                CbEvent.BEGIN, InteractionType.COLLISION,
                _heroCbType, _wallCbType, _onHeroToWall
            );

            addInitializer(function():void {
                _hero.cbTypes.add(_heroCbType);
                _physicsSpace.listeners.add(_interactionListener);

                listen(GameEvent.TRIGGER_JUMP, _onTriggerJump);
            });
        }

        protected override function onInitWallBody(body:Body):void {
            body.cbTypes.add(_wallCbType);
        }

        private function _onHeroToWall(cb:InteractionCallback):void {
            var hero:Body = cb.int1.castBody;
            var wall:Body = cb.int2.castBody;

            // 着地判定（ToDo: これだとまだ甘い。地上近くの側面との接触でジャンプ繰り返せちゃう）
            if (hero.position.y < wall.position.y - wall.userData.height/2) {
                _onHeroLanding();
            }
        }

        private function _onHeroLanding():void {
            _jumpLife = 2;
        }

        protected override function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX * 300;
        }

        private function _onTriggerJump(args:Object):void {
            if (_jumpLife == 0) { return; }

            --_jumpLife;
            _hero.velocity.y = -430;
        }

        public override function onUpdate(passedTime:Number):void {
            _hero.velocity.x = _velocityX;
            if (_hero.velocity.y > 650) { _hero.velocity.y = 650; }

            _physicsSpace.step(passedTime);

            _tileMapDisplay.x = 240 - _hero.position.x;
            _tileMapDisplay.y = 160 - _hero.position.y;
        }

    }
}
