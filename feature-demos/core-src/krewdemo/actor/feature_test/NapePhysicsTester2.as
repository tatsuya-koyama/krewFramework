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
    public class NapePhysicsTester2 extends NapePhysicsTester1 {

        //------------------------------------------------------------
        public function NapePhysicsTester2() {
            addInitializer(function():void {
                addPeriodicTask(0.02, function():void {
                    _addRandomBox(10, 20);
                });
            });
        }

    }
}
