package krewfw_builtin_actor.tests {

    import org.flexunit.Assert;

    import krewfw.builtin_actor.system.KrewState;
    import krewfw.builtin_actor.system.KrewStateMachine;
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
                enter: function(state:KrewState):void { signal = 101; }
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
                exit: function(state:KrewState):void { signal = 102; }
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

        [Test]
        public function test_eventTransition_2():void {
            var fsm:KrewStateMachine = new KrewStateMachine([
                {
                    id: "state_10",
                    listen: [
                        {event: "event_C", to: "state_14"},
                        {event: "event_B", to: "state_10_4_3"}
                    ],
                    children: [
                        {id: "state_10_1", listen: {event: "-", to: "-"}},
                        {id: "state_10_2", listen: {event: "event_C", to: "state_13"}},
                        {id: "state_10_3", listen: {event: "-", to: "-"}},
                        {
                            id: "state_10_4",
                            listen: {event: "event_A", to: "state_12"},
                            children: [
                                {id: "state_10_4_1", listen: {event: "-", to: "-"}},
                                {id: "state_10_4_2", listen: {event: "-", to: "-"}},
                                {id: "state_10_4_3", listen: {event: "event_A", to: "state_11"}}
                            ]
                        },
                        {id: "state_10_5", listen: {event: "-", to: "-"}}
                    ]
                },
                {id: "state_11", listen: {event: "-", to: "-"}},
                {id: "state_12", listen: {event: "-", to: "-"}},
                {id: "state_13", listen: {event: "-", to: "-"}},
                {id: "state_14", listen: {event: "-", to: "-"}}
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            var anActor:KrewActor = new KrewActor();
            scene.setUpActor(null, anActor);

            Assert.assertEquals(true, fsm.isState("state_10"));

            anActor.sendMessage("event_B");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_10_4_3"));

            anActor.sendMessage("event_A");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_11"));

            // delegate 10_4_2 -> 10_4
            fsm.changeState("state_10_4_2");
            anActor.sendMessage("event_A");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_12"));

            // delegate 10_4_1 -> 10_4 -> 10
            fsm.changeState("state_10_4_1");
            anActor.sendMessage("event_C");
            scene.mainLoop();
            Assert.assertEquals(true, fsm.isState("state_14"));
        }

        [Test]
        public function test_defaultNext():void {
            var fsm:KrewStateMachine = new KrewStateMachine([
                {id: "state_20", children: [
                    {id: "state_20_1"},
                    {id: "state_20_2", next: "state_22"},
                    {id: "state_20_3"},
                    {id: "state_20_4", children: [
                        {id: "state_20_4_1"},
                        {id: "state_20_4_2"},
                        {id: "state_20_4_3", next: "state_20_1"}
                    ]},
                    {id: "state_20_5"},
                    {id: "state_20_6", children: [
                        {id: "state_20_6_1", children: [
                            {id: "state_20_6_1_1"}
                        ]}
                    ]}
                ]},
                {id: "state_21"},
                {id: "state_22", children: [
                    {id: "state_22_1", children: [
                        {id: "state_22_1_1"}
                    ]},
                    {id: "state_22_2"}
                ]},
                {id: "state_23"},
                {id: "state_24"}
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            Assert.assertEquals("state_20_1"     , fsm.getState("state_20"      ).nextStateId);
            Assert.assertEquals("state_22"       , fsm.getState("state_20_2"    ).nextStateId);
            Assert.assertEquals("state_20_4"     , fsm.getState("state_20_3"    ).nextStateId);
            Assert.assertEquals("state_20_4_1"   , fsm.getState("state_20_4"    ).nextStateId);
            Assert.assertEquals("state_22"       , fsm.getState("state_21"      ).nextStateId);
            Assert.assertEquals("state_20_1"     , fsm.getState("state_20_4_3"  ).nextStateId);
            Assert.assertEquals("state_20_6_1"   , fsm.getState("state_20_6"    ).nextStateId);
            Assert.assertEquals("state_20_6_1_1" , fsm.getState("state_20_6_1"  ).nextStateId);
            Assert.assertEquals("state_21"       , fsm.getState("state_20_6_1_1").nextStateId);
            Assert.assertEquals("state_23"       , fsm.getState("state_22_2"    ).nextStateId);
            Assert.assertEquals(null             , fsm.getState("state_24"      ).nextStateId);
        }

        [Test]
        public function test_proceed():void {
            var trail:String = "";
            var state31:KrewState = new KrewState({id: "state_31"});

            var fsm:KrewStateMachine = new KrewStateMachine([
                {
                    id   : "state_30",
                    next : "state_32",
                    enter: function(state:KrewState):void { trail += "a";  state.proceed(); }
                },
                state31,
                {id: "state_32", children: [
                    {
                        id   : "state_32_1",
                        enter: function(state:KrewState):void { trail += "b";  state.proceed(); }
                    },
                    {
                        id   : "state_32_2",
                        enter: function(state:KrewState):void { trail += "c";  state.proceed(); }
                    }
                ]},
                {
                    id   : "state_33",
                    next : "state_30",
                    enter: function(state:KrewState):void { trail += "d";  state.proceed(); }
                }
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            Assert.assertEquals("state_32", fsm.currentState.stateId);

            fsm.changeState("state_31");
            state31.proceed();
            Assert.assertEquals("state_32", fsm.currentState.stateId);

            fsm.changeState("state_32_1");
            state31.proceed();
            Assert.assertEquals("state_32", fsm.currentState.stateId);

            Assert.assertEquals("abcda", trail);
        }

        [Test]
        public function test_guardFunc():void {
            var condition:int = 0;

            var fsm:KrewStateMachine = new KrewStateMachine([
                {
                    id: "state_40",
                    listen: {event: "event40_A", to: "state_40_3_1_1"},
                    guard : function(state:KrewState):Boolean { return (condition > 100); },
                    children: [
                        {
                            id: "state_40_1"
                        },
                        {
                            id: "state_40_2"
                        },
                        {
                            id: "state_40_3",
                            listen: {event: "event40_B", to: "state_41"},
                            children: [
                                {
                                    id: "state_40_3_1",
                                    children: [
                                        {
                                            id: "state_40_3_1_1",
                                            guard : function(state:KrewState):Boolean { return false; }
                                        }
                                    ]
                                },
                                {
                                    id: "state_40_3_2"
                                }
                            ]
                        }
                    ]
                },
                {
                    id: "state_41"
                }
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            var anActor:KrewActor = new KrewActor();
            scene.setUpActor(null, anActor);

            // condition is NG
            anActor.sendMessage("event40_A");
            scene.mainLoop();
            Assert.assertEquals("state_40", fsm.currentState.stateId);

            // condition is OK
            condition = 101;
            anActor.sendMessage("event40_A");
            scene.mainLoop();
            Assert.assertEquals("state_40_3_1_1", fsm.currentState.stateId);

            // bubbling event
            // 子 state の無関係のイベントに対する guard は実行されない
            anActor.sendMessage("event40_B");
            scene.mainLoop();
            Assert.assertEquals("state_41", fsm.currentState.stateId);
        }

        [Test]
        public function test_onUpdateHandler():void {
            var trail:String = "";

            var fsm:KrewStateMachine = new KrewStateMachine([
                {
                    id: "state_50",
                    update : function(state:KrewState, passedTime:Number):void {
                        trail += "a";
                    },
                    children: [
                        {
                            id: "state_50_1",
                            update : function(state:KrewState, passedTime:Number):void {
                                trail += "b";
                            },
                            children: [
                                {
                                    id: "state_50_1_1",
                                    update : function(state:KrewState, passedTime:Number):void {
                                        trail += "c";
                                    }
                                }
                            ]
                        }
                    ]
                },
                {
                    id: "state_41"
                }
            ]);

            var scene:KrewScene = KrewTestUtil.getScene();
            scene.setUpActor(null, fsm);

            scene.mainLoop();
            Assert.assertEquals("a", trail);

            fsm.changeState("state_50_1_1");
            scene.mainLoop();
            Assert.assertEquals("acba", trail);

            fsm.changeState("state_50_1");
            scene.mainLoop();
            Assert.assertEquals("acbaba", trail);
        }

    }
}
