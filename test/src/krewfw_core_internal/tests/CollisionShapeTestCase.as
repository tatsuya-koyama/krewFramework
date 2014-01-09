package krewfw_core_internal.tests {

    import org.flexunit.Assert;

    import krewfw.core.KrewActor;
    import krewfw.core_internal.collision.CollisionShape;
    import krewfw.core_internal.collision.CollisionShapeAABB;
    import krewfw.core_internal.collision.CollisionShapeOBB;
    import krewfw.core_internal.collision.CollisionShapeSphere;
    import krewfw.utils.krew;

    public class CollisionShapeTestCase {

        private var onCollide:Function = function():void {};
        private var actorA:KrewActor = new KrewActor();
        private var actorB:KrewActor = new KrewActor();
        private var aabbA:CollisionShapeAABB;
        private var aabbB:CollisionShapeAABB;
        private var obbA:CollisionShapeOBB;
        private var obbB:CollisionShapeOBB;
        private var sphereA:CollisionShapeSphere;
        private var sphereB:CollisionShapeSphere;

        [Before]
        public function runBeforeTest():void {
            aabbA = new CollisionShapeAABB(
                actorA, onCollide, 200, 100, 0, 0
            );
            aabbB = new CollisionShapeAABB(
                actorB, onCollide, 200, 400, 0, 0
            );
            obbA = new CollisionShapeOBB(
                actorA, onCollide, 200, 100, 0, 0
            );
            obbB = new CollisionShapeOBB(
                actorB, onCollide, 200, 400, 0, 0
            );
            sphereA = new CollisionShapeSphere(
                actorA, onCollide, 100, 0, 0
            );
            sphereB = new CollisionShapeSphere(
                actorB, onCollide, 200, 0, 0
            );
        }

        [Test]
        public function hitTestAABBvsAABB_1():void {
            actorA.x = 0;
            actorA.y = 0;

            actorB.x = -250;
            actorB.y = 250;

            var isHit:Boolean = aabbA.hitTest(aabbB);
            Assert.assertEquals(isHit, false);
        }

        [Test]
        public function hitTestAABBvsAABB_2():void {
            actorA.x = 0;
            actorA.y = 0;

            actorB.x = -190;
            actorB.y = 250;

            var isHit:Boolean = aabbA.hitTest(aabbB);
            Assert.assertEquals(isHit, true);
        }

        [Test]
        public function hitTestOBBvsOBB_1():void {
            actorA.x = 0;
            actorA.y = 0;
            actorA.rotation = krew.deg2rad(45);

            actorB.x = -300;
            actorB.y = 0;
            actorB.rotation = krew.deg2rad(0);

            var isHit:Boolean = obbA.hitTest(obbB);
            Assert.assertEquals(isHit, false);
        }

        [Test]
        public function hitTestOBBvsOBB_2():void {
            actorA.x = 0;
            actorA.y = 0;
            actorA.rotation = krew.deg2rad(45);

            actorB.x = -200;
            actorB.y = 0;
            actorB.rotation = krew.deg2rad(-45);

            var isHit:Boolean = obbA.hitTest(obbB);
            Assert.assertEquals(isHit, true);
        }

        [Test]
        public function hitTestSphereVsSphere_1():void {
            actorA.x = 0;
            actorA.y = 0;

            actorB.x = -300;
            actorB.y = -10;

            var isHit:Boolean = sphereA.hitTest(sphereB);
            Assert.assertEquals(isHit, false);
        }

        [Test]
        public function hitTestSphereVsSphere_2():void {
            actorA.x = 0;
            actorA.y = 0;

            actorB.x = -290;
            actorB.y = 0;

            var isHit:Boolean = sphereA.hitTest(sphereB);
            Assert.assertEquals(isHit, true);
        }

        [Test]
        public function hitTestAABBVsOBB_1():void {
            actorA.x = -210;
            actorA.y = 0;

            actorB.x = 0;
            actorB.y = 0;
            actorB.rotation = krew.deg2rad(-30);

            var isHit:Boolean = aabbA.hitTest(obbB);
            Assert.assertEquals(isHit, true);
        }

        [Test]
        public function hitTestAABBVsSphere_1():void {
            actorA.x = -190;
            actorA.y = 0;

            actorB.x = 0;
            actorB.y = 0;

            var isHit:Boolean = aabbA.hitTest(sphereB);
            Assert.assertEquals(isHit, true);
        }

        [Test]
        public function hitTestOBBVsSphere_1():void {
            actorA.x = -200;
            actorA.y = 0;
            actorA.rotation = krew.deg2rad(30);

            actorB.x = 0;
            actorB.y = 0;

            var isHit:Boolean = obbA.hitTest(sphereB);
            Assert.assertEquals(isHit, true);
        }
    }
}
