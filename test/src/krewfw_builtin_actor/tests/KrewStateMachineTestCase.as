package krewfw_builtin_actor.tests {

    import org.flexunit.Assert;

    import krewfw.builtin_actor.KrewState;
    import krewfw.builtin_actor.KrewStateMachine;

    public class KrewStateMachineTestCase {

        [Test]
        public function test_onEnter():void {
            var signal:int = 0;
            var fsm:KrewStateMachine = new KrewStateMachine();
            var state1:KrewState = new KrewState({
                id: "test_state_1",
                enter: function():void { signal = 101; }
            });

            fsm.addState(state1);
            Assert.assertEquals(0, signal);

            fsm.changeState("test_state_1");
            Assert.assertEquals(101, signal);
        }

        [Test]
        public function test_onExit():void {
            var signal:int = 0;
            var fsm:KrewStateMachine = new KrewStateMachine();
            var state1:KrewState = new KrewState({id: "test_state_1"});
            var state2:KrewState = new KrewState({
                id: "test_state_2",
                exit: function():void { signal = 102; }
            });

            fsm.addState(state1);
            fsm.addState(state2);
            Assert.assertEquals(0, signal);

            fsm.changeState("test_state_1");
            Assert.assertEquals(0, signal);

            fsm.changeState("test_state_2");
            Assert.assertEquals(0, signal);

            fsm.changeState("test_state_1");
            Assert.assertEquals(102, signal);
        }

    }
}
