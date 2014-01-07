package krewdemo.actor.feature_test {

    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import Box2D.Dynamics.*;
    import Box2D.Collision.*;
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;

    import krewfw.NativeStageAccessor;
    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TileMapHelper;

    //------------------------------------------------------------
    public class Box2DPhysicsTester1 extends KrewActor {

        // pixels to meter
        private const P2M:Number = 40;

        private const _debugDrawMode:Boolean = false;

        private var _physicsWorld:b2World;

        private var _myBox:b2Body;

        //------------------------------------------------------------
        public override function init():void {
            // create physics world
            var gravity:b2Vec2  = new b2Vec2(0, 13.0);
            var doSleep:Boolean = true;
            _physicsWorld = new b2World(gravity, doSleep);

            _initDebugDraw();
            _initMyBox();
            _initFloor();
            _initSlope();

            addPeriodicTask(0.5, function():void {
                _addRandomBox();
            });
            addPeriodicTask(1.2, function():void {
                _addRandomBall();
            });

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        protected override function onDispose():void {
            for (var body:b2Body = _physicsWorld.GetBodyList();  body;  body = body.GetNext()) {
                _physicsWorld.DestroyBody(body);
            }
            _physicsWorld = null;
        }

        private function _initDebugDraw():void {
            if (!_debugDrawMode) { return; }

            var debugDraw:b2DebugDraw = new b2DebugDraw();
            debugDraw.SetSprite(NativeStageAccessor.rootSprite);
            debugDraw.SetDrawScale(P2M * (NativeStageAccessor.stage.stageWidth / 480));
            debugDraw.SetFillAlpha(0.3);
            debugDraw.SetLineThickness(1.0);
            debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);

            _physicsWorld.SetDebugDraw(debugDraw);
            _physicsWorld.DrawDebugData();
        }

        private function _initMyBox():void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            bodyDef.position.Set(240 / P2M, 50 / P2M);

            var boxShape:b2PolygonShape = new b2PolygonShape();
            boxShape.SetAsBox(
                20 / P2M * 0.97,
                20 / P2M * 0.97
            );

            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape       = boxShape;
            fixtureDef.friction    = 0.5;
            fixtureDef.density     = 1.0;
            fixtureDef.restitution = 0.3;

            // starling display
            var image:Image = getImage('rectangle_taro');
            addImage(image, 20*2, 20*2);
            image.x     = bodyDef.position.x * P2M;
            image.y     = bodyDef.position.y * P2M;
            image.color = 0xffaaaa;
            bodyDef.userData = new Object();
            bodyDef.userData.displayObject = image;
            bodyDef.userData.isMyBox = true;

            var body:b2Body = _physicsWorld.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);

            _myBox = body;
        }

        private function _initFloor():void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_staticBody;
            bodyDef.position.Set(290 / P2M, 290 / P2M);

            var boxShape:b2PolygonShape = new b2PolygonShape();
            boxShape.SetAsBox(
                120 / P2M * 0.97,
                 16 / P2M * 0.97
            );

            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape    = boxShape;
            fixtureDef.friction = 0.3;
            fixtureDef.density  = 0;  // in Box2D, static bodies require zero density

            var body:b2Body = _physicsWorld.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);

            // starling display
            var image:Image = getImage('long_bar');
            addImage(image, 120*2, 16*2);
            image.x     = bodyDef.position.x * P2M;
            image.y     = bodyDef.position.y * P2M;
            image.color = 0x99ccff;
        }

        private function _initSlope():void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_staticBody;
            bodyDef.position.Set(-30 / P2M, 80 / P2M);
            bodyDef.angle = krew.deg2rad(30);

            var boxShape:b2PolygonShape = new b2PolygonShape();
            boxShape.SetAsBox(
                150 / P2M * 0.97,
                 16 / P2M * 0.97
            );

            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape    = boxShape;
            fixtureDef.friction = 0.3;
            fixtureDef.density  = 0;  // in Box2D, static bodies require zero density

            var body:b2Body = _physicsWorld.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);

            // starling display
            var image:Image = getImage('long_bar');
            addImage(image, 150*2, 16*2);
            image.x        = bodyDef.position.x * P2M;
            image.y        = bodyDef.position.y * P2M;
            image.rotation = bodyDef.angle;
            image.color    = 0x99ccff;
        }

        protected function _addRandomBox(minSize:Number=10, maxSize:Number=70):void {
            var size:Number = krew.randArea(minSize, maxSize);

            // Box2D physics body
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            var x:Number = krew.randArea(50, 430);
            var y:Number = -100;
            bodyDef.position.Set(x / P2M, y / P2M);
            bodyDef.angle = krew.randArea(0, 6.28);

            var boxShape:b2PolygonShape = new b2PolygonShape();
            boxShape.SetAsBox(
                size / 2 / P2M * 0.97,
                size / 2 / P2M * 0.97
            );

            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape       = boxShape;
            fixtureDef.friction    = 0.4;
            fixtureDef.density     = 2.0;
            fixtureDef.restitution = 0.4;

            // starling display
            var image:Image = getImage('rectangle_taro');
            addImage(image, size, size, bodyDef.position.x, bodyDef.position.y);
            image.x = bodyDef.position.x * P2M;
            image.y = bodyDef.position.y * P2M;
            bodyDef.userData = new Object();
            bodyDef.userData.displayObject = image;

            // register to physics world
            var body:b2Body = _physicsWorld.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);
        }

        protected function _addRandomBall(minSize:Number=10, maxSize:Number=50):void {
            var size:Number = krew.randArea(minSize, maxSize);

            // Box2D physics body
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            var x:Number = -50;
            var y:Number = 0;
            bodyDef.position.Set(x / P2M, y / P2M);
            bodyDef.angle = krew.randArea(0, 6.28);

            var ballShape:b2CircleShape = new b2CircleShape(size / 2 / P2M * 0.97);

            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape       = ballShape;
            fixtureDef.friction    = 0.5;
            fixtureDef.density     = 1.0;
            fixtureDef.restitution = 0.2;

            // starling display
            var image:Image = getImage('circle_jiro');
            addImage(image, size, size, bodyDef.position.x, bodyDef.position.y);
            image.x     = bodyDef.position.x * P2M;
            image.y     = bodyDef.position.y * P2M;
            image.color = 0xccff88;
            bodyDef.userData = new Object();
            bodyDef.userData.displayObject = image;

            // register to physics world
            var body:b2Body = _physicsWorld.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);
        }

        public override function onUpdate(passedTime:Number):void {
            var velocityIterations:int = 10;
            var positionIterations:int = 10;
            _physicsWorld.Step(passedTime, velocityIterations, positionIterations);
            //_physicsWorld.ClearForces();

            if (_debugDrawMode) {
                _physicsWorld.DrawDebugData();
            }

            _loopMyBoxPos();

            _updateObjects();
        }

        private function _loopMyBoxPos():void {
            var x:Number = _myBox.GetPosition().x;
            var y:Number = _myBox.GetPosition().y;

            if (y > 400 / P2M) {
                _myBox.SetPosition(new b2Vec2(x, -50 / P2M));
            }
            if (x < -100 / P2M) {
                _myBox.SetPosition(new b2Vec2((480 + 50) / P2M, y));
            }
            if (x > (480 + 100) / P2M) {
                _myBox.SetPosition(new b2Vec2(-50 / P2M, y));
            }
        }

        private function _updateObjects():void {
            for (var body:b2Body = _physicsWorld.GetBodyList();  body;  body = body.GetNext()) {
                var userData:Object = body.GetUserData() as Object;
                if (userData == null) { continue; }

                var image:Image = userData.displayObject;
                image.x = body.GetPosition().x * P2M;
                image.y = body.GetPosition().y * P2M;
                image.rotation = body.GetAngle();

                // kill
                if (image.y > 340) {
                    if (!userData.isMyBox) {
                        _physicsWorld.DestroyBody(body);
                        removeChild(image);
                        image.texture.dispose();
                        image.dispose();
                    }
                }
            }
        }

        private function _onUpdateJoystick(args:Object):void {
            _myBox.SetLinearVelocity(new b2Vec2(
                args.velocityX * 12.0,
                args.velocityY * 12.0
            ));
        }

    }
}
