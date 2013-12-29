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
    import nape.space.Space;
    import nape.util.BitmapDebug;
    import nape.util.Debug;

    import krewfw.builtin_actor.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.starling_utility.TileMapHelper;
    import krewfw.utility.KrewUtil;

    //------------------------------------------------------------
    public class NapePhysicsTester1 extends KrewActor {

        private var _physicsSpace:Space;

        private var _myBox:Body;
        private var _myBoxDisplay:Image;

        private var _floor:Body;
        private var _floorDisplay:Image;

        private var _slope:Body;
        private var _slopeDisplay:Image;

        private var _objects:Array = new Array();

        //------------------------------------------------------------
        public override function init():void {
            var gravity:Vec2 = Vec2.weak(0, 500);
            _physicsSpace = new Space(gravity);

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
            /**
             * [Note] シーン遷移でメモリが解放されないように見えるが、
             *        無限には増え続けず、ある程度消費が増えると少し解放されたり
             *        消費が止まったりという挙動になる。
             *
             *        できればシーン遷移のタイミングで解放できるものはしてしまいたい…
             *        Nape のオブジェクトのプーリングと関係しているかもしれない。
             */
             _physicsSpace.clear();
        }

        private function _initMyBox():void {
            // nape physics body
            _myBox = new Body(BodyType.DYNAMIC);
            var boxShape:Polygon = new Polygon(Polygon.box(38, 38));
            boxShape.material = Material.steel();
            _myBox.shapes.add(boxShape);
            _myBox.position.setxy(240, 50);
            _physicsSpace.bodies.add(_myBox);

            // starling display
            _myBoxDisplay = getImage('rectangle_taro');
            addImage(_myBoxDisplay, 40, 40);
            _myBoxDisplay.x     = _myBox.position.x;
            _myBoxDisplay.y     = _myBox.position.y;
            _myBoxDisplay.color = 0xffaaaa;
        }

        private function _initFloor():void {
            // nape physics body
            _floor = new Body(BodyType.STATIC);
            var floorShape:Polygon = new Polygon(Polygon.box(240, 32));
            floorShape.material = Material.wood();
            _floor.shapes.add(floorShape);
            _floor.position.setxy(290, 290);
            _physicsSpace.bodies.add(_floor);

            // starling display
            _floorDisplay = getImage('long_bar');
            addImage(_floorDisplay, 240, 34);
            _floorDisplay.x     = _floor.position.x;
            _floorDisplay.y     = _floor.position.y;
            _floorDisplay.color = 0x99ccff;
        }

        private function _initSlope():void {
            // nape physics body
            _slope = new Body(BodyType.STATIC);
            var floorShape:Polygon = new Polygon(Polygon.box(300, 32));
            floorShape.material = Material.wood();
            _slope.shapes.add(floorShape);
            _slope.position.setxy(-30, 80);
            _slope.rotation = KrewUtil.deg2rad(30);
            _physicsSpace.bodies.add(_slope);

            // starling display
            _slopeDisplay = getImage('long_bar');
            addImage(_slopeDisplay, 300, 34);
            _slopeDisplay.x        = _slope.position.x;
            _slopeDisplay.y        = _slope.position.y;
            _slopeDisplay.rotation = _slope.rotation;
            _slopeDisplay.color    = 0x99ccff;
        }

        protected function _addRandomBox(minSize:Number=10, maxSize:Number=70):void {
            // nape physics body
            var body:Body = new Body(BodyType.DYNAMIC);

            var size:Number = KrewUtil.randArea(minSize, maxSize);
            var vertices:Array = Polygon.box(size * 0.97, size * 0.97);

            var shape:Polygon = new Polygon(vertices);
            shape.material = Material.glass();
            body.shapes.add(shape);

            var x:Number = KrewUtil.randArea(50, 430);
            var y:Number = -100;
            body.position.setxy(x, y);
            body.rotation = KrewUtil.randArea(0, 6.28);
            _physicsSpace.bodies.add(body);

            // starling display
            var image:Image = getImage('rectangle_taro');
            addImage(image, size, size, body.position.x, body.position.y);
            body.userData.displayObject = image;

            _objects.push(body);
        }

        private function _addRandomBall(minSize:Number=10, maxSize:Number=50):void {
            // nape physics body
            var body:Body = new Body(BodyType.DYNAMIC);

            var size:Number = KrewUtil.randArea(minSize, maxSize);
            var shape:Circle = new Circle(size * 0.485);
            shape.material = Material.steel();
            body.shapes.add(shape);

            var x:Number = -50
            var y:Number = 0;
            body.position.setxy(x, y);
            body.rotation = KrewUtil.randArea(0, 6.28);
            _physicsSpace.bodies.add(body);

            // starling display
            var image:Image = getImage('circle_jiro');
            addImage(image, size, size, body.position.x, body.position.y);
            image.color = 0xccff88;
            body.userData.displayObject = image;

            _objects.push(body);
        }

        public override function onUpdate(passedTime:Number):void {
            _physicsSpace.step(passedTime);

            _loopMyBoxPos();

            // update box display
            _myBoxDisplay.x = _myBox.position.x;
            _myBoxDisplay.y = _myBox.position.y;
            _myBoxDisplay.rotation = _myBox.rotation;

            // Floor and slope are static object. Display update is not necessary.

            _updateObjects();
        }

        private function _loopMyBoxPos():void {
            if (_myBox.position.y > 400) {
                _myBox.position.y = -50;
            }
            if (_myBox.position.x < -100) {
                _myBox.position.x = 480 + 50;
            }
            if (_myBox.position.x > 480 + 100) {
                _myBox.position.x = -50;
            }
        }

        private function _updateObjects():void {
            for (var i:int = 0;  i < _objects.length;  ++i) {
                var body:Body = _objects[i];
                body.userData.displayObject.x = body.position.x;
                body.userData.displayObject.y = body.position.y;
                body.userData.displayObject.rotation = body.rotation;

                // kill
                if (body.position.y > 340) {
                    _physicsSpace.bodies.remove(body);
                    var image:Image = body.userData.displayObject;
                    removeChild(image);
                    image.texture.dispose();
                    image.dispose();

                    _objects.splice(i, 1);
                    --i;
                }
            }
        }

        private function _onUpdateJoystick(args:Object):void {
            _myBox.velocity.setxy(
                args.velocityX * 400.0,
                args.velocityY * 400.0
            );
        }

    }
}
