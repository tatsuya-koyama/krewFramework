package krewdemo.actor.feature_test {

    import starling.display.Image;
    import starling.display.QuadBatch;
    import starling.textures.Texture;
    import starling.textures.TextureSmoothing;

    import krewfw.builtin_actor.ui.SimpleVirtualJoystick;
    import krewfw.core.KrewActor;
    import krewfw.utils.starling.TileMapHelper;

    //------------------------------------------------------------
    public class CreateActorTester extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {
            addPeriodicTask(0.01, function():void {
                for (var i:int=0;  i < 5;  ++i) {
                    createActor(new SimpleWalkActor());
                }
            });
        }

    }
}
