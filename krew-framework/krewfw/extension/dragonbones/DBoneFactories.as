package krewfw.extension.dragonbones {

    import flash.events.Event;
    import flash.utils.Dictionary;

    import dragonBones.Armature;
    import dragonBones.factorys.StarlingFactory;

    import krewfw.utils.krew;
    import krewfw.utils.as3.KrewAsync;

    /**
     * Repository of DragonBones Starling factory.
     *
     * <pre>
     * USAGE:
     *   1. Load DragonBones asset files to krewFramework's resource manager as ByteArray.
     *
     *       // Your scene class
     *       public override function getRequiredAssets():Array {
     *           return ["animation/hero.swf", "animation/monster.swf"];
     *       }
     *
     *   2. Initialize DragonBones Starling factories with resource name
     *      (resource name is asset file name without extension by default.)
     *
     *       // in KrewScene.hookBeforeInit()
     *       var dBoneFactories = new DBoneFactories();
     *       dBoneFactories.initFactories(["hero", "monster"], onCompleteHandler);
     *
     *   3. Get DragoneBones armature instance.
     *
     *       armature = dBoneFactories.makeArmature("hero", "MovieClipName_in_hero.swf");
     *
     * </pre>
     */
    //------------------------------------------------------------
    public class DBoneFactories {

        private var _factories:Dictionary;

        //------------------------------------------------------------
        public function DBoneFactories() {
            _factories = new Dictionary();
        }

        //------------------------------------------------------------
        // public user interface
        //------------------------------------------------------------

        public function initFactories(resourceKeys:Array, onComplete:Function):void {
            var taskList:Array = [];
            for each (var resourceKey:String in resourceKeys) {
                var task:Function = _makeInitFactoryTask(resourceKey);
                taskList.push(task);
            }

            krew.async({
                parallel: taskList,
                anyway  : onComplete
            });
        }

        public function dispose():void {
            for (var key:String in _factories) {
                _factories[key].dispose();
                delete _factories[key];
            }
        }

        public function makeArmature(resourceKey:String, boneName:String):Armature {
            if (!_factories[resourceKey]) {
                throw new Error("Factory not found: " + resourceKey);
            }

            return _factories[resourceKey].buildArmature(boneName);
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _makeInitFactoryTask(resourceKey:String):Function {
            return function(async:KrewAsync):void {
                var factory:StarlingFactory = new StarlingFactory();
                _factories[resourceKey] = factory;

                factory.addEventListener(Event.COMPLETE, function(event:Event):void {
                    async.done();
                });
                factory.parseData(krew.agent.getByteArray(resourceKey));
            };
        }

    }
}
