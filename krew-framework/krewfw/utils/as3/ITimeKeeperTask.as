package krewfw.utils.as3 {

    public interface ITimeKeeperTask {

        function update(passedTime:Number):void;

        function dispose():void;

        function isDead():Boolean;

    }
}
