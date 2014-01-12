package krewfw_builtin_actor.tests {

    import org.flexunit.Assert;

    import krewfw.builtin_actor.KrewState;
    import krewfw.builtin_actor.KrewStateMachine;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewScene;
    import krewfw.utils.dev_tool.KrewTestUtil;

    public class KrewStateMachineTestCase {

        private function _getSampleStateTree():Array {
            /**
             *                    +- s6 --- s8
             *             +- s2 -+- s4 --- s7
             *  s0 --- s1 -+
             *             +- s3 --- s5 --- s9
             */
            var state0:KrewState = new KrewState({id: "s0"});
            var state1:KrewState = new KrewState({id: "s1"});
            var state2:KrewState = new KrewState({id: "s2"});
            var state3:KrewState = new KrewState({id: "s3"});
            var state4:KrewState = new KrewState({id: "s4"});
            var state5:KrewState = new KrewState({id: "s5"});
            var state6:KrewState = new KrewState({id: "s6"});
            var state7:KrewState = new KrewState({id: "s7"});
            var state8:KrewState = new KrewState({id: "s8"});
            var state9:KrewState = new KrewState({id: "s9"});
            state0.addState(state1);
            state1.addState(state2);
            state1.addState(state3);
            state2.addState(state4);
            state2.addState(state6);
            state3.addState(state5);
            state4.addState(state7);
            state5.addState(state9);
            state6.addState(state8);

            return [state0, state1, state2, state3, state4,
                    state5, state6, state7, state8, state9];
        }

        [Test]
        public function test_eachChild():void {
            var stateList:Array = _getSampleStateTree();
            var trail:String;

            // from state3
            trail = "";
            stateList[3].eachChild(function(state:KrewState):void {
                trail += state.stateId;
            });
            Assert.assertEquals("s3s5s9", trail);

            // from state2
            trail = "";
            stateList[2].eachChild(function(state:KrewState):void {
                trail += state.stateId;
            });
            Assert.assertEquals("s2s4s7s6s8", trail);
        }

        [Test]
        public function test_eachParent():void {
            var stateList:Array = _getSampleStateTree();
            var trail:String;

            // from state4
            trail = "";
            stateList[4].eachParent(function(state:KrewState):void {
                trail += state.stateId;
            });
            Assert.assertEquals("s4s2s1s0", trail);
        }

        [Test]
        public function test_isState_1():void {
            var stateList:Array = _getSampleStateTree();
            var rootState:KrewState = stateList[0];
            var fsm:KrewStateMachine = new KrewStateMachine([rootState]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            Assert.assertEquals(true,  fsm.isState("s0"));

            fsm.changeState("s4");
            Assert.assertEquals(true,  fsm.isState("s4"));
            Assert.assertEquals(true,  fsm.isState("s2"));
            Assert.assertEquals(true,  fsm.isState("s1"));
            Assert.assertEquals(true,  fsm.isState("s0"));
            Assert.assertEquals(false, fsm.isState("s7"));

            fsm.changeState("s5");
            Assert.assertEquals(false, fsm.isState("s2"));
            Assert.assertEquals(false, fsm.isState("s9"));
            Assert.assertEquals(true,  fsm.isState("s5"));
            Assert.assertEquals(true,  fsm.isState("s3"));
        }

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

        [Test]
        public function test_eventTransition_1():void {
            var fsm:KrewStateMachine = new KrewStateMachine([
                {
                    id: "state_1",
                    listen: {event: "event_1_to_2", to: "state_2"}
                },
                {
                    id: "state_2",
                    listen: {event: "event_2_to_3", to: "state_3"}
                },
                {
                    id: "state_3"
                },
                {
                    id: "state_4",
                    listen: [
                        {event: "event_4_to_1", to: "state_1"},
                        {event: "event_4_to_2", to: "state_2"}
                    ]
                }
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            var anActor:KrewActor = new KrewActor();
            scene.setUpActor(null, anActor);

            Assert.assertEquals(true, fsm.isState("state_1"));

            // non related event
            anActor.sendMessage("event_2_to_3");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_1"));

            // notable event
            anActor.sendMessage("event_1_to_2");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_2"));

            // forgot events of past state
            fsm.changeState("state_4");
            anActor.sendMessage("event_2_to_3");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_4"));

            // multi listening
            fsm.changeState("state_4");
            anActor.sendMessage("event_4_to_1");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_1"));

            fsm.changeState("state_4");
            anActor.sendMessage("event_4_to_2");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_2"));
        }

    }
}
