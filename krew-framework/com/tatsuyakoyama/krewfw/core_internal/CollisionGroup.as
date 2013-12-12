package com.tatsuyakoyama.krewfw.core_internal {

    import com.tatsuyakoyama.krewfw.core_internal.collision.CollisionShape;

    import com.tatsuyakoyama.krewfw.utility.KrewUtil;
    import com.tatsuyakoyama.krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class CollisionGroup {

        private var _groupName:String;
        private var _collidableGroups:Vector.<CollisionGroup> = new Vector.<CollisionGroup>();
        private var _shapes:Vector.<CollisionShape> = new Vector.<CollisionShape>;

        //------------------------------------------------------------
        public function get collidableGroups():Vector.<CollisionGroup> {
            return _collidableGroups;
        }

        public function get shapes():Vector.<CollisionShape> {
            return _shapes;
        }

        public function get groupName():String {
            return _groupName;
        }

        //------------------------------------------------------------
        public function CollisionGroup(groupName:String) {
            _groupName = groupName;
        }

        public function dispose():void {}

        public function addCollidableGroup(collidableGroup:CollisionGroup):void {
            _collidableGroups.push(collidableGroup);
        }

        public function addShape(shape:CollisionShape):void {
            _shapes.push(shape);
        }

        public function removeShape(owner:KrewActor):Boolean {
            for (var i:int=0;  i < _shapes.length;  ++i) {
                var shape:CollisionShape = _shapes[i];
                if (shape.owner.id == owner.id) {
                    _shapes.splice(i, 1);  // remove shape from Array
                    return true;
                }
            }

            KrewUtil.fwlog('Shape not registered. [owner id: ' + owner.id + ']');
            return false;
        }

        /**
         * Do hit test and call both collided shape's handlers
         * with arguments [otherGroupName:String, otherShape:CollisionShape]
         */
        public function hitTest(otherGroup:CollisionGroup):void {
            for each (var shape:CollisionShape in _shapes) {
                for each (var otherShape:CollisionShape in otherGroup.shapes) {
                    if (shape.hitTest(otherShape)) {
                        shape.handler(otherGroup.groupName, otherShape);
                        otherShape.handler(groupName, shape);
                    }
                }
            }
        }
    }
}
