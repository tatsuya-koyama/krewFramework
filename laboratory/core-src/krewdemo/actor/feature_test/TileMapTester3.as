package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.phys.Material;
    import nape.shape.Circle;
    import nape.shape.Polygon;
    import nape.shape.Shape;
    import nape.space.Space;
    import nape.util.BitmapDebug;
    import nape.util.Debug;

    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TileMapHelper;
    import krewfw.utility.KrewUtil;

    //------------------------------------------------------------
    public class TileMapTester3 extends KrewActor {

        protected var _physicsSpace:Space;
        protected var _gravity:Number = 0;

        protected var _tileMapDisplay:QuadBatch;

        protected var _hero:Body;

        protected var _velocityX:Number = 0;
        protected var _velocityY:Number = 0;

        //------------------------------------------------------------
        public override function init():void {
            var gravity:Vec2 = Vec2.weak(0, _gravity);
            _physicsSpace = new Space(gravity);

            _tileMapDisplay = _makeMapDisplay();
            _tileMapDisplay.scaleX = 1.0;
            _tileMapDisplay.scaleY = 1.0;
            addChild(_tileMapDisplay);

            _initHero();
            _initWallCollision();

            listen(SimpleVirtualJoystick.UPDATE_JOYSTICK, _onUpdateJoystick);
        }

        protected override function onDispose():void {
            _physicsSpace.bodies.foreach(function(body:Body):void {
                _removePhysicsBody(body);
            });
            _physicsSpace.bodies.clear();

            _physicsSpace.clear();
            _physicsSpace = null;
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

        private function _makeMapDisplay():QuadBatch {
            var tileMapInfo:Object = getObject('testmap_001');
            var tileLayer:Object   = TileMapHelper.getLayerByName(tileMapInfo, "background");
            var tileSet:Object     = tileMapInfo.tilesets[0];

            var quadBatch:QuadBatch  = new QuadBatch();
            var tilesTexture:Texture = getTexture(tileSet.name);

            for (var row:int = 0;  row < 79;  ++row) {
                for (var col:int = 0;  col < 103;  ++col) {

                    var image:Image = TileMapHelper.getTileImage(
                        tileMapInfo, tileLayer, tileSet, tilesTexture, col, row
                    );
                    if (!image) { continue; }

                    image.x = col * tileSet.tilewidth;
                    image.y = row * tileSet.tileheight;
                    image.smoothing = TextureSmoothing.NONE;

                    quadBatch.addImage(image);
                }
            }

            return quadBatch;
        }

        private function _initHero():void {
            var physX:Number  = 200;
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
            shape.material.density         = 1.0;
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

        private function _initWallCollision():void {
            var tileMapInfo:Object    = getObject('testmap_001');
            var collisionLayer:Object = TileMapHelper.getLayerByName(tileMapInfo, "wall_collision");
            var collisionObjs:Array   = collisionLayer.objects;

            for each (var obj:Object in collisionObjs) {
                _makeCollisionBody(obj.x, obj.y, obj.width, obj.height);
            }
        }

        private function _makeCollisionBody(x:Number, y:Number, width:Number, height:Number):void {
            if (width == 0  ||  height == 0) {
                throw new Error("invalid wall size: (" + x/32 + ", " + y/32 + ")");
            }

            var body:Body = new Body(BodyType.STATIC);
            var shape:Polygon = new Polygon(Polygon.box(width, height, true));
            body.shapes.add(shape);
            body.position.setxy(x + width/2, y + height/2);
            _physicsSpace.bodies.add(body);

            body.userData.width  = width;
            body.userData.height = height;
            onInitWallBody(body);

            // debug display
            // var image:Image = getImage('long_bar');
            // addImage(image, width, height, x + width/2, y + height/2);
            // image.color = 0x6688aa;
            // image.alpha = 0.5;
            // body.userData.displayObj = image;
        }

        protected function onInitWallBody(body:Body):void {}

        protected function _onUpdateJoystick(args:Object):void {
            _velocityX = args.velocityX * 300;
            _velocityY = args.velocityY * 300;
        }

        public override function onUpdate(passedTime:Number):void {
            _hero.velocity.setxy(_velocityX, _velocityY);

            _physicsSpace.step(passedTime);

            var heroImage:Image = _hero.userData.displayObj;
            heroImage.rotation = _hero.rotation;
            // heroImage.x = _hero.position.x;
            // heroImage.y = _hero.position.y;

            _tileMapDisplay.x = 240 - _hero.position.x;
            _tileMapDisplay.y = 160 - _hero.position.y;
        }

    }
}
