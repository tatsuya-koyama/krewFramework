package krewdemo.actor.feature_test {

    import flash.display.Stage;
    import flash.geom.Rectangle;

    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.display.Sprite;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import nape.geom.Vec2;
    import nape.geom.GeomPoly;
    import nape.geom.GeomPolyList;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.phys.Material;
    import nape.shape.Circle;
    import nape.shape.Polygon;
    import nape.shape.Shape;
    import nape.space.Space;
    import nape.util.BitmapDebug;
    import nape.util.Debug;

    import nape.callbacks.CbEvent;
    import nape.callbacks.CbType;
    import nape.callbacks.InteractionCallback;
    import nape.callbacks.InteractionListener;
    import nape.callbacks.InteractionType;

    import krewfw.NativeStageAccessor;
    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TileMapHelper;

    import krewdemo.GameEvent;
    import krewdemo.scene.PlatformerTestScene1;

    //------------------------------------------------------------
    public class PlatformerTester1 extends KrewActor {

        private const _debugMode:Boolean = false;

        protected var _physicsSpace:Space;
        protected var _gravity:Number = 900;

        protected var _tileMapDisplays:Array = [];
        private   var _clouds:Sprite;

        protected var _hero:Body;

        protected var _velocityX:Number = 0;
        protected var _velocityY:Number = 0;

        private var _interactionListener:InteractionListener;
        private var _wallCbType:CbType = new CbType();
        private var _heroCbType:CbType = new CbType();

        private var _jumpLife:int = 2;

        private var _isSceneEnding:Boolean = false;
        private var _debugDraw:Debug;

        //------------------------------------------------------------
        public override function init():void {
            var gravity:Vec2 = Vec2.weak(0, _gravity);
            _physicsSpace = new Space(gravity);

            _clouds = _makeClouds();
            addChild(_clouds);

            for (var i:int=0;  i < 2;  ++i) {
                _tileMapDisplays[i] = _makeMapDisplay("view_" + (i + 1));
                _tileMapDisplays[i].scaleX = 1.0;
                _tileMapDisplays[i].scaleY = 1.0;
                addChild(_tileMapDisplays[i]);
            }

            _initWallCollision("collision_1", 0.0);
            _initWallCollision("collision_bound", 4.0);
            _initHero();
            _initDebugDraw();

            _interactionListener = new InteractionListener(
                CbEvent.BEGIN, InteractionType.COLLISION,
                _heroCbType, _wallCbType, _onHeroToWall
            );

            _hero.cbTypes.add(_heroCbType);
            _physicsSpace.listeners.add(_interactionListener);

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
            listen(GameEvent.TRIGGER_JUMP, _onTriggerJump);
        }

        protected override function onDispose():void {
            _physicsSpace.bodies.foreach(function(body:Body):void {
                _removePhysicsBody(body);
            });
            _physicsSpace.bodies.clear();

            _physicsSpace.clear();
            _physicsSpace = null;

            if (_debugDraw) {
                _debugDraw.clear();
                NativeStageAccessor.stage.removeChild(_debugDraw.display);
                _debugDraw = null;
            }

            removeChild(_clouds);
            _clouds = null;
        }

        private function _removePhysicsBody(body:Body):void {
            _physicsSpace.bodies.remove(body);

            var image:Image = body.userData.displayObj;
            if (image) {
                removeChild(image);
                image.texture.dispose();
                image.dispose();
            }

            body.shapes.foreach(function(shape:Shape):void {
                shape.body = null;
                shape = null;
            });
            body.shapes.clear();
            body.space = null;
            body = null;
        }

        private function _initHero():void {
            var physX:Number  = 240;
            var physY:Number  = 160;
            var imageX:Number = 240;
            var imageY:Number = 160;
            var size:Number   = 32 * 0.94;

            // nape physics body
            var body:Body = new Body(BodyType.DYNAMIC);
            var shape:Polygon = new Polygon(Polygon.box(size * 0.9, size * 0.9, true));
            shape.material.elasticity      = 0.0;
            shape.material.dynamicFriction = 0.0;
            shape.material.staticFriction  = 0.0;
            shape.material.density         = 4.0;
            shape.material.rollingFriction = 1.0;
            body.shapes.add(shape);
            body.position.setxy(physX, physY);
            body.allowRotation = false;
            _physicsSpace.bodies.add(body);

            // starling display
            var image:Image = getImage('rectangle_taro');
            addImage(image, size, size, imageX, imageY);
            body.userData.displayObj = image;

            _hero = body;
        }

        //----------------------------------------------------------------------
        // load level-map view
        //----------------------------------------------------------------------

        private function _makeMapDisplay(layerName:String):QuadBatch {
            var levelInfo:Object = getObject("level_1");
            var quadBatch:QuadBatch  = new QuadBatch();

            for each (var el:Object in levelInfo.layers[layerName].elements) {
                var image:Image = getImage(el.name);

                var textureRect:Rectangle = image.texture.frame;
                image.pivotX = (textureRect.width  * 0.5);
                image.pivotY = (textureRect.height * 0.5);

                image.x        = el.x;
                image.y        = el.y;
                image.width    = el.width;
                image.height   = el.height;
                image.rotation = krew.deg2rad(el.rotation);

                quadBatch.addImage(image);
            }

            return quadBatch;
        }

        private function _makeClouds():Sprite {
            var sprite:Sprite = new Sprite();

            krew.times(16, function():void {
                var image:Image = getImage("cloud_1");

                image.x = krew.rand(-300, 480 + 300);
                image.y = krew.rand(-200, 320 + 200);

                var scale:Number = krew.rand(0.4, 1.0);
                image.scaleX = scale;
                image.scaleY = scale;

                sprite.addChild(image);
            });

            return sprite;
        }

        //----------------------------------------------------------------------
        // load collision
        //----------------------------------------------------------------------

        private function _initWallCollision(layerName:String, elasticity:Number=0):void {
            var levelInfo:Object = getObject("level_1");

            for each (var vertices:Array in levelInfo.layers[layerName].polygons) {
                _makeCollisionBody(vertices, elasticity);
            }
        }

        private function _makeCollisionBody(vertices:Array, elasticity:Number=0):void {
            var vecList:Array = [];
            for each (var vertex:Object in vertices) {
                vecList.push(Vec2.get(vertex.x, vertex.y));
            }

            var geomPolySrc:GeomPoly = new GeomPoly(vecList);
            var geomPolyList:GeomPolyList = geomPolySrc.convexDecomposition();

            geomPolyList.foreach(function(geomPoly:GeomPoly):void {
                _addConvexCollision(geomPoly, elasticity);
            });
        }

        private function _addConvexCollision(geomPoly:GeomPoly, elasticity:Number=0):void {
            var body:Body = new Body(BodyType.STATIC);
            var shape:Polygon = new Polygon(geomPoly);
            shape.material.elasticity = elasticity;  // これ 2.0 とかにすればジャンプ床できる

            body.shapes.add(shape);
            _physicsSpace.bodies.add(body);

            body.cbTypes.add(_wallCbType);
        }

        //----------------------------------------------------------------------
        // landing detection
        //----------------------------------------------------------------------

        private function _onHeroToWall(cb:InteractionCallback):void {
            var hero:Body = cb.int1.castBody;
            var wall:Body = cb.int2.castBody;

            // ToDo: 着地判定をちゃんとやる
            _onHeroLanding();

            // if (hero.position.y < wall.position.y - wall.userData.height/2) {
            //     _onHeroLanding();
            // }
        }

        private function _onHeroLanding():void {
            _jumpLife = 2;
        }

        //----------------------------------------------------------------------
        // update handlers
        //----------------------------------------------------------------------

        protected function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX * 300;
        }

        private function _onTriggerJump(args:Object):void {
            if (_jumpLife == 0) { return; }

            --_jumpLife;
            _hero.velocity.y = -430;
        }

        public override function onUpdate(passedTime:Number):void {
            // physics
            _hero.velocity.x = _velocityX;
            if (_hero.velocity.y > 2000) { _hero.velocity.y = 2000; }

            _physicsSpace.step(passedTime);

            // view
            var cloudDepth:Number = 0.2;
            _clouds.x = 240 - (_hero.position.x * cloudDepth);
            _clouds.y = 160 - (_hero.position.y * cloudDepth);
            
            for (var i:int=0;  i < _tileMapDisplays.length;  ++i) {
                _tileMapDisplays[i].x = 240 - _hero.position.x;
                _tileMapDisplays[i].y = 160 - _hero.position.y;
            }

            var heroImage:Image = _hero.userData.displayObj;
            heroImage.rotation = _hero.rotation;

            _onUpdatePhysicsDebugDraw();

            // out of world border
            _checkExitWorld();
        }

        private function _checkExitWorld():void {
            if (_isSceneEnding) { return; }

            if (_hero.position.y > 1000) {
                _isSceneEnding = true;
                sendMessage(GameEvent.NEXT_SCENE, {nextScene: new PlatformerTestScene1});
            }
        }

        //----------------------------------------------------------------------
        // nape debug display
        //----------------------------------------------------------------------

        private function _initDebugDraw():void {
            if (!_debugMode) { return; }

            var stage:Stage = NativeStageAccessor.stage;
            _debugDraw = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color);

            var scale:Number = stage.stageWidth / 480;
            _debugDraw.display.scaleX = scale;
            _debugDraw.display.scaleY = scale;
            _debugDraw.display.alpha  = 0.5;

            stage.addChild(_debugDraw.display);
        }

        private function _onUpdatePhysicsDebugDraw():void {
            if (!_debugDraw) { return; }

            var scale:Number = NativeStageAccessor.stage.stageWidth / 480;
            _debugDraw.display.x = (240 - _hero.position.x) * scale;
            _debugDraw.display.y = (160 - _hero.position.y) * scale;

            _debugDraw.clear();
            _debugDraw.draw(_physicsSpace);
            _debugDraw.flush();
        }

    }
}
