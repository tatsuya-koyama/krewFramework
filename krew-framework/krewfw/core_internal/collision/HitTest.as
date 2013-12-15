package krewfw.core_internal.collision {

    import krewfw.utility.KrewPoint2D;
    import krewfw.utility.KrewVector2D;

    /**
     * Collision detection algorithm library
     */
    //------------------------------------------------------------
    public class HitTest {

        // AABB を OBB に変換して判定するときの作業用オブジェクト
        // インスタンス化のコストを避けるため static で持つ
        private static var _workingOBB:CollisionShapeOBB = new CollisionShapeOBB(null, null, 0, 0);

        //------------------------------------------------------------
        public function HitTest() {}

        public static function hitTestSphereVsSphere(_shape:CollisionShape,
                                                     _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeSphere = _shape as CollisionShapeSphere;
            var other:CollisionShapeSphere = _other as CollisionShapeSphere;

            shape.update();
            other.update();

            // compute factors
            var dx:Number   = shape.x - other.x;
            var dy:Number   = shape.y - other.y;
            var rSum:Number = shape.radius + other.radius;
            var squareDistance:Number = (dx * dx) + (dy * dy);

            // collision detection
            return (rSum * rSum >= squareDistance);
        }

        public static function hitTestAABBVsAABB(_shape:CollisionShape,
                                                 _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeAABB = _shape as CollisionShapeAABB;
            var other:CollisionShapeAABB = _other as CollisionShapeAABB;

            shape.update();
            other.update();

            // collision detection
            if (shape.maxX < other.minX  ||  shape.minX > other.maxX) { return false; }
            if (shape.maxY < other.minY  ||  shape.minY > other.maxY) { return false; }
            return true;
        }

        public static function hitTestOBBVsOBB(_shape:CollisionShape,
                                               _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeOBB = _shape as CollisionShapeOBB;
            var other:CollisionShapeOBB = _other as CollisionShapeOBB;

            shape.update();
            other.update();

            if (!_separatingAxisTest(shape, other, 0)) { return false; }
            if (!_separatingAxisTest(shape, other, 1)) { return false; }
            if (!_separatingAxisTest(other, shape, 0)) { return false; }
            if (!_separatingAxisTest(other, shape, 1)) { return false; }
            return true;
        }

        public static function hitTestSphereVsAABB(_shape:CollisionShape,
                                                   _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeSphere = _shape as CollisionShapeSphere;
            var other:CollisionShapeAABB   = _other as CollisionShapeAABB;

            shape.update();
            other.update();

            // collision detection with square distance to closest point
            var sqDist:Number = _computeSquareDistanceFromPointToAABB(
                shape.x, shape.y, other
            );
            return (sqDist <= shape.radius * shape.radius);
        }

        public static function hitTestSphereVsOBB(_shape:CollisionShape,
                                                  _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeSphere = _shape as CollisionShapeSphere;
            var other:CollisionShapeOBB    = _other as CollisionShapeOBB;

            shape.update();
            other.update();

            // collision detection with square distance to closest point
            var closestPoint:KrewPoint2D = _getClosestPointFromPointToOBB(
                shape.x, shape.y, other
            );
            var diffVec:KrewVector2D = new KrewVector2D(
                closestPoint.x - shape.x,
                closestPoint.y - shape.y
            );
            return (diffVec.dotProduct(diffVec) <= (shape.radius * shape.radius));
        }

        public static function hitTestAABBVsOBB(_shape:CollisionShape,
                                                _other:CollisionShape):Boolean {
            // downcasting
            var shape:CollisionShapeAABB = _shape as CollisionShapeAABB;
            var other:CollisionShapeOBB  = _other as CollisionShapeOBB;

            shape.update();
            CollisionShapeOBB.copyFromAABB(shape, _workingOBB);
            other.update();

            if (!_separatingAxisTest(_workingOBB, other, 0)) { return false; }
            if (!_separatingAxisTest(_workingOBB, other, 1)) { return false; }
            if (!_separatingAxisTest(other, _workingOBB, 0)) { return false; }
            if (!_separatingAxisTest(other, _workingOBB, 1)) { return false; }
            return true;
        }

        //------------------------------------------------------------
        // private methods
        //------------------------------------------------------------

        /**
         * 全ての分離軸上で重なっている射影がないかテストする
         */
        private static function _separatingAxisTest(shape:CollisionShapeOBB,
                                                    other:CollisionShapeOBB,
                                                    localBasisVectorIndex:int):Boolean {
            var separatingAxis:KrewVector2D;
            var projectedALength:Number;
            var projectedBLength:Number;
            var projectedDistance:Number;
            var isOverlapped:Boolean;

            separatingAxis    = shape.localBasisVectors[localBasisVectorIndex];
            projectedALength  = shape.halfSideLengths  [localBasisVectorIndex];
            projectedBLength  = _computeProjectedLength(other, separatingAxis);
            projectedDistance = _computeProjectedDistance(shape, other, separatingAxis);
            isOverlapped = _isOverlappedOnSeparatingAxis(
                projectedALength, projectedBLength, projectedDistance
            );
            return isOverlapped;
        }

        /**
         * 分離軸への射影の長さを、ドット積を計算して返す
         */
        private static function _computeProjectedLength(obb:CollisionShapeOBB,
                                                        separatingAxis:KrewVector2D):Number {
            var dot0:Number = obb.sideVectors[0].dotProduct(separatingAxis);
            var dot1:Number = obb.sideVectors[1].dotProduct(separatingAxis);
            return (Math.abs(dot0) + Math.abs(dot1));
        }

        /**
         * ２つの OBB の間の射影の長さ（分離軸上での距離）を計算して返す
         */
        private static function _computeProjectedDistance(obb:CollisionShapeOBB,
                                                          other:CollisionShapeOBB,
                                                          separatingAxis:KrewVector2D):Number {
            var distanceVector:KrewVector2D = new KrewVector2D(
                obb.x - other.x,
                obb.y - other.y
            );
            var dot:Number = distanceVector.dotProduct(separatingAxis);
            return Math.abs(dot);
        }

        /**
         * 分離軸上の A の射影の長さと B の射影の長さの合計が
         * A, B の中心点の射影の距離に満たなければ、
         * A, B の分離軸上の射影は重なっている
         */
        private static function _isOverlappedOnSeparatingAxis(projectedALength:Number,
                                                              projectedBLength:Number,
                                                              projectedDistance:Number):Boolean {
            return (projectedALength + projectedBLength > projectedDistance);
        }

        /**
         * 点から AABB までの最近接点を求める
         */
        private static function _getClosestPointFromPointToAABB(x:Number, y:Number,
                                                                aabb:CollisionShapeAABB):KrewPoint2D {
            var closestX:Number = x;
            if (closestX < aabb.minX) { closestX = aabb.minX; }
            if (closestX > aabb.maxX) { closestX = aabb.maxX; }

            var closestY:Number = y;
            if (closestY < aabb.minY) { closestY = aabb.minY; }
            if (closestY > aabb.maxY) { closestY = aabb.maxY; }

            return new KrewPoint2D(closestX, closestY);
        }

        /**
         * 点から AABB までの最短距離の２乗を計算して返す
         */
        private static function _computeSquareDistanceFromPointToAABB(x:Number, y:Number,
                                                                      aabb:CollisionShapeAABB):Number {
            var sqDist:Number = 0;

            if (x < aabb.minX) { sqDist += (aabb.minX - x) * (aabb.minX - x); }
            if (x > aabb.maxX) { sqDist += (x - aabb.maxX) * (x - aabb.maxX); }

            if (y < aabb.minY) { sqDist += (aabb.minY - y) * (aabb.minY - y); }
            if (y > aabb.maxY) { sqDist += (y - aabb.maxY) * (y - aabb.maxY); }

            return sqDist;
        }

        /**
         * 点から OBB までの最近接点を求める
         */
        private static function _getClosestPointFromPointToOBB(x:Number, y:Number,
                                                               obb:CollisionShapeOBB):KrewPoint2D
        {
            // (OBB.center - point) vector
            var diffVec:KrewVector2D = new KrewVector2D(
                x - obb.x,
                y - obb.y
            );
            // start at center of the OBB
            var closestPoint:KrewPoint2D = new KrewPoint2D(
                obb.x, obb.y
            );

            var distX:Number = diffVec.dotProduct(obb.localBasisVectors[0]);
            if (distX >  obb.halfSideLengths[0]) { distX =  obb.halfSideLengths[0]; }
            if (distX < -obb.halfSideLengths[0]) { distX = -obb.halfSideLengths[0]; }
            closestPoint.addVectorWithScale(obb.localBasisVectors[0], distX);

            var distY:Number = diffVec.dotProduct(obb.localBasisVectors[1]);
            if (distY >  obb.halfSideLengths[1]) { distY =  obb.halfSideLengths[1]; }
            if (distY < -obb.halfSideLengths[1]) { distY = -obb.halfSideLengths[1]; }
            closestPoint.addVectorWithScale(obb.localBasisVectors[1], distY);

            return closestPoint;
        }
    }
}
