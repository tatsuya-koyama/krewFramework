package krewfw_data_structure.tests {

    import org.flexunit.Assert;
    import org.hamcrest.assertThat;
    import org.hamcrest.collection.array;
    import mx.utils.ObjectUtil;

    import krewfw.data_structure.PriorityQueue;

    public class KrewPriorityQueueTestCase {

        [Test]
        public function test_peek():void {
            var pq:PriorityQueue = new PriorityQueue();
            pq.enqueue(1, "item_1");
            pq.enqueue(0, "item_2");
            pq.enqueue(5, "item_3");
            pq.enqueue(3, "item_4");

            Assert.assertEquals(pq.peek(), "item_2");
            Assert.assertEquals(pq.length, 4);
        }

        [Test]
        public function test_enqueue():void {
            var pq:PriorityQueue = new PriorityQueue();

            pq.enqueue(4, "item_1");
            Assert.assertEquals(pq.peek(), "item_1");
            Assert.assertEquals(pq.length, 1);

            pq.enqueue(3, "item_2");
            Assert.assertEquals(pq.peek(), "item_2");
            Assert.assertEquals(pq.length, 2);

            pq.enqueue(0, "item_3");
            Assert.assertEquals(pq.peek(), "item_3");
            Assert.assertEquals(pq.length, 3);

            pq.enqueue(1, "item_4");
            Assert.assertEquals(pq.peek(), "item_3");
            Assert.assertEquals(pq.length, 4);
        }

        [Test]
        public function test_dequeue():void {
            var pq:PriorityQueue = new PriorityQueue();
            pq.enqueue(4, "item_1");
            pq.enqueue(3, "item_2");
            pq.enqueue(0, "item_3");
            pq.enqueue(1, "item_4");
            pq.enqueue(2, "item_5");

            Assert.assertEquals(pq.dequeue(), "item_3");
            Assert.assertEquals(pq.length, 4);

            Assert.assertEquals(pq.dequeue(), "item_4");
            Assert.assertEquals(pq.length, 3);

            Assert.assertEquals(pq.dequeue(), "item_5");
            Assert.assertEquals(pq.length, 2);

            Assert.assertEquals(pq.dequeue(), "item_2");
            Assert.assertEquals(pq.length, 1);

            Assert.assertEquals(pq.dequeue(), "item_1");
            Assert.assertEquals(pq.length, 0);

            Assert.assertEquals(pq.dequeue(), null);
            Assert.assertEquals(pq.length, 0);
        }

        [Test]
        public function test_enqueue_and_dequeue():void {
            var pq:PriorityQueue = new PriorityQueue();
            pq.enqueue(4, "item_1");
            pq.enqueue(0, "item_2");
            pq.enqueue(3, "item_3");  // [0, 3, 4]

            Assert.assertEquals(pq.peek(),    "item_2");
            Assert.assertEquals(pq.dequeue(), "item_2");
            Assert.assertEquals(pq.length, 2);  // [3, 4]

            pq.enqueue(0, "item_4");
            pq.enqueue(1, "item_5");  // [0, 1, 3, 4]

            Assert.assertEquals(pq.peek(),    "item_4");
            Assert.assertEquals(pq.dequeue(), "item_4");
            Assert.assertEquals(pq.length, 3);  // [1, 3, 4]

            pq.enqueue(2, "item_6");
            pq.enqueue(2, "item_7");  // [1, 2, 2, 3, 4]

            Assert.assertEquals(pq.peek(),    "item_5");
            Assert.assertEquals(pq.dequeue(), "item_5");
            Assert.assertEquals(pq.length, 4);

            pq.dequeue()
            pq.dequeue()  // [3, 4]
            Assert.assertEquals(pq.peek(),    "item_3");
            Assert.assertEquals(pq.dequeue(), "item_3");
            Assert.assertEquals(pq.length, 1);  // [4]
        }

    }
}
