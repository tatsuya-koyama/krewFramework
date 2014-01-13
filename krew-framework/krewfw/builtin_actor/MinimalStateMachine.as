package krewfw.builtin_actor {

    import krewfw.core.KrewActor;

    /**
     * [Note] Now new Hierarchical Finite State Machine is available.
     *        You should use it in serious project.
     *
     * Simple State Machine Actor. Use this with MinimalStateHook.
     * Usage Example:
     *
     *     private var _state:KrewStateMachine = new KrewStateMachine();
     *
     *     private function initState():void {
     *         _state.initWithObj({
     *             push_start : null,
     *             select_menu: new MinimalStateHook(_onSelectMenuState),
     *             transition: {
     *                 goto_tutorial: new MinimalStateHook(_onTutorial),
     *                 goto_normal  : null,
     *                 goto_crazy   : null
     *             }
     *         });
     *         _state.switchState('push_start');
     *         setUpActor('_system_', _state, false);
     *     }
     *
     *     public override function getNextScene():KrewScene {
     *         // set play mode
     *         switch (_state.currentState) {
     *         case 'transition.goto_tutorial':
     *             return new TutorialScene();  break;
     *             ...
     *     }
     */
    //------------------------------------------------------------
    public class MinimalStateMachine extends KrewActor {

        private var _states:Object = new Object();
        private var _currentState:String = null;

        //------------------------------------------------------------
        public function get currentState():String {
            return _currentState;
        }

        //------------------------------------------------------------
        public function MinimalStateMachine() {}

        /**
         * @param stateTree Example:
         *     {
         *         idle: stateHook1,
         *         attack: {
         *             shoot: {
         *                 rapid: null,
         *                 soft : null
         *             },
         *             tackle: null
         *         },
         *         defense: {
         *             guard: stateHook2,
         *             avoid: null
         *         }
         *     }
         *
         * This method converts given object into a flat dictionary as below:
         *     {
         *         'idle'              : stateHook1
         *         'attack.shoot.rapid': null
         *         'attack.shoot.soft' : null
         *         'attack.tackle'     : null
         *         'defense.guard'     : stateHook2
         *         'defense.avoid'     : null
         *     }
         */
        public function initWithObj(stateTree:Object):void {
            _states = krew.flattenObject(stateTree);
        }

        public function switchState(state:String):void {
            if (!(state in _states)) {
                throw new Error('Undefined state: ' + state);
            }

            // after-hook
            var stateHook:*;
            stateHook = _states[_currentState];
            if (stateHook  &&  stateHook is MinimalStateHook) {
                stateHook.invokeAfterHooks();
            }

            // change state
            _currentState = state;

            // before-hook
            stateHook = _states[_currentState];
            if (stateHook  &&  stateHook is MinimalStateHook) {
                stateHook.invokeBeforeHooks();
            }
        }

        /**
         * Return true if given state is current state or belongs to current state group.
         * For example, isState('attack.shoot') returns true when the current state
         * is 'attack.shoot.rapid' or 'attack.shoot.soft'.
         */
        public function isState(state:String):Boolean {
            // _currentState.search(state) == 0 とどっちが速いかは分からん
            var pattern:RegExp = new RegExp('^' + state);
            if (_currentState.match(pattern)) {
                return true;
            }
            return false;
        }
    }
}
