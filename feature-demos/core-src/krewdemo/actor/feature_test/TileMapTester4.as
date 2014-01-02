package krewdemo.actor.feature_test {

    import nape.callbacks.CbEvent;
    import nape.callbacks.CbType;
    import nape.callbacks.InteractionCallback;
    import nape.callbacks.InteractionListener;
    import nape.callbacks.InteractionType;
    import nape.phys.Body;

    //------------------------------------------------------------
    public class TileMapTester4 extends TileMapTester3 {

        private var _interactionListener:InteractionListener;
        private var _wallCbType:CbType = new CbType();
        private var _heroCbType:CbType = new CbType();

        private var _jumpLife:int = 2;
        private var _jumpKeyReady:Boolean = true;

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
            });
        }

        protected override function onInitWallBody(body:Body):void {
            body.cbTypes.add(_wallCbType);
        }

        private function _onHeroToWall(cb:InteractionCallback):void {
            var hero:Body = cb.int1.castBody;
            var wall:Body = cb.int2.castBody;

            // 着地判定
            if (hero.position.y < wall.position.y - wall.userData.height/2) {
                _onHeroLanding();
            }
        }

        private function _onHeroLanding():void {
            _jumpLife = 2;
        }

        protected override function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX * 300;

            // jump
            if (_jumpLife > 0  &&  _jumpKeyReady  &&  args.velocityY < -0.5) {
                --_jumpLife;
                _jumpKeyReady = false;
                _hero.velocity.y = -430;
            }
            if (args.velocityY > -0.5) {
                _jumpKeyReady = true;
            }
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
