package krewdemo.actor.world_test {

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class BGObjectActor extends KrewActor {

        //------------------------------------------------------------
        public override function init():void {

        }

        protected override function onDispose():void {

        }

        public override function onUpdate(passedTime:Number):void {
            rotation += 0.5 * passedTime;
        }

    }
}
