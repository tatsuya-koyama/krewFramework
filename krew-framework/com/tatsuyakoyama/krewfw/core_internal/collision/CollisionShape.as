package com.tatsuyakoyama.krewfw.core_internal.collision {

    import com.tatsuyakoyama.krewfw.core.KrewActor;

    import com.tatsuyakoyama.krewfw.utility.KrewUtil;

    /**
     * Shape data for collision detection.
     * This class knows subclasses of itself
     * to choose collision detection algorithms.
     */
    //------------------------------------------------------------
    public class CollisionShape {

        public static const SHAPE_SPHERE:int = 1;
        public static const SHAPE_AABB  :int = 2;
        public static const SHAPE_OBB   :int = 3;

        public var _owner:KrewActor;
        public var _handler:Function;
        public var _type:int = 0;

        public var offsetX:Number;
        public var offsetY:Number;

        //------------------------------------------------------------
        public function get owner():KrewActor {
            return _owner;
        }

        public function get handler():Function {
            return _handler;
        }

        public function get type():int {
            return _type;
        }

        public function get x():Number {
            return owner.x + offsetX;
        }

        public function get y():Number {
            return owner.y + offsetY;
        }

        //------------------------------------------------------------
        public function CollisionShape(owner:KrewActor, handler:Function,
                                         offsetX:Number=0, offsetY:Number=0)
        {
            _owner   = owner;
            _handler = handler;
            this.offsetX = offsetX;
            this.offsetY = offsetY;
        }

        public function hitTest(other:CollisionShape):Boolean {
            // ignore self-intersection
            if (this.owner.id == other.owner.id) { return false; }

            if (!this.owner.collidable  ||  !other.owner.collidable) { return false; }

            // I want to write collision detection with double dispatch pattern
            // but unfortunately ActionScript3.0 cannot use function overloading...

            // Sphere vs Sphere
            if (    this is CollisionShapeSphere
                && other is CollisionShapeSphere) {
                return HitTest.hitTestSphereVsSphere(this, other);
            }
            // AABB vs AABB
            else if (    this is CollisionShapeAABB
                     && other is CollisionShapeAABB) {
                return HitTest.hitTestAABBVsAABB(this, other);
            }
            // OBB vs OBB
            else if (    this is CollisionShapeOBB
                     && other is CollisionShapeOBB) {
                return HitTest.hitTestOBBVsOBB(this, other);
            }
            // Sphere vs AABB
            else if (    this is CollisionShapeSphere
                     && other is CollisionShapeAABB) {
                return HitTest.hitTestSphereVsAABB(this, other);
            }
            else if (    this is CollisionShapeAABB
                     && other is CollisionShapeSphere) {
                return HitTest.hitTestSphereVsAABB(other, this);
            }
            // Sphere vs OBB
            else if (    this is CollisionShapeSphere
                     && other is CollisionShapeOBB) {
                return HitTest.hitTestSphereVsOBB(this, other);
            }
            else if (    this is CollisionShapeOBB
                     && other is CollisionShapeSphere) {
                return HitTest.hitTestSphereVsOBB(other, this);
            }
            // AABB vs OBB
            else if (    this is CollisionShapeAABB
                     && other is CollisionShapeOBB) {
                return HitTest.hitTestAABBVsOBB(this, other);
            }
            else if (    this is CollisionShapeOBB
                     && other is CollisionShapeAABB) {
                return HitTest.hitTestAABBVsOBB(other, this);
            }

            KrewUtil.fwlog('[Error] This shape combination is not supported.');
            return false;
        }
    }
}
