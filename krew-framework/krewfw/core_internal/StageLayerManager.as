package krewfw.core_internal {

    import flash.utils.Dictionary;

    import starling.display.DisplayObject;

    import krewfw.builtin_actor.display.ScreenFader;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewScene;
    import krewfw.utils.krew;

    //------------------------------------------------------------
    public class StageLayerManager {

        /** {"layername": <StageLayer>} */
        private var _layers:Dictionary = new Dictionary;
        private var _globalLayersCache:Dictionary = new Dictionary;

        /** Array of layer name (String) in order from back to front. */
        private var _displayOrder:Array;
        private var _globalDisplayOrder:Array = [];

        private var _screenFader:ScreenFader;

        //------------------------------------------------------------
        public function StageLayerManager() {}

        //------------------------------------------------------------
        // Called by System (You should not call directly)
        //------------------------------------------------------------

        /**
         * Called by KrewScene.
         *
         * displayOrder で指定したレイヤー名の順に奥から並ぶ.
         * 例えば ['back', 'middle', 'front'] を渡すと back レイヤーが一番奥になる。
         * そして暗黙で最前面に '_system_' レイヤーが足されるので
         * _system_ という名前は使わないように注意
         */
        public function setUpLayers(scene:KrewScene, displayOrder:Array):void {
            displayOrder.push('_system_');

            // create and add scene-scope layers
            for each (var layerName:String in displayOrder) {
                _addLayer(scene, layerName);
            }

            // add global-scope layers from cache
            for each (var globalLayerName:String in _globalDisplayOrder) {
                var globalLayer:StageLayer = _globalLayersCache[globalLayerName];
                _addLayer(scene, globalLayerName, globalLayer);
                _resetGlobalActorsContext(globalLayer);
            }

            _displayOrder = displayOrder.concat(_globalDisplayOrder);
            _setUpScreenFader();
        }

        public function makeGlobalLayers(displayOrder:Array):void {
            for each (var layerName:String in displayOrder) {
                var globalLayer:StageLayer = new StageLayer();
                _globalLayersCache[layerName] = globalLayer;
            }
            _globalDisplayOrder = displayOrder;
        }

        public function disposeAllSceneScopeLayers():void {
            for (var layerName:String in _layers) {
                if (_globalLayersCache[layerName] != null) {
                    delete _layers[layerName];
                    continue;
                }

                _layers[layerName].dispose();
                delete _layers[layerName];
                krew.fwlog('--- dispose Layer: ' + layerName);
            }
            _displayOrder = new Array(); // clear array
        }

        public function removeGlobalLayersFromScene(scene:KrewScene):void {
            for each (var layerName:String in _globalDisplayOrder) {
                var globalLayer:StageLayer = _globalLayersCache[layerName];
                scene.removeChild(globalLayer);

                // Layer が次の Scene にセットし直されたときに、
                // 各 Actor がその Scene 用に初期化され直すようにする
                for each (var child:KrewActor in globalLayer.childActors) {
                    child.hasInitialized = false;
                }
            }
        }

        public function addActor(layerName:String, actor:KrewActor,
                                 putOnDisplayList:Boolean=true):Boolean {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return false;
            }

            _layers[layerName].addActor(actor, putOnDisplayList);
            return true;
        }

        public function addChild(layerName:String, displayObj:DisplayObject):Boolean {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return false;
            }

            _layers[layerName].addChild(displayObj);
            return true;
        }

        public function onUpdate(passedTime:Number):void {
            // update layers in display order (from back to front)
            for each (var layerName:String in _displayOrder) {
                _layers[layerName].onUpdate(passedTime);
            }
        }

        //------------------------------------------------------------
        // public interfaces
        //------------------------------------------------------------

        public function getLayer(layerName:String):StageLayer {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return null;
            }

            return _layers[layerName];
        }

        public function setTimeScale(layerName:String, timeScale:Number):Boolean {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return false;
            }

            _layers[layerName].timeScale = timeScale;
            return true;
        }

        public function resetTimeScale(layerName:String):void {
            setTimeScale(layerName, 1);
        }

        public function killActors(layerName:String):Boolean {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return false;
            }

            for each (var child:KrewActor in _layers[layerName].childActors) {
                child.passAway();
            }
            return true;
        }

        //------------------------------------------------------------
        // Fade In/Out Helper
        //------------------------------------------------------------

        private function _setUpScreenFader():void {
            _screenFader = new ScreenFader();
            addActor('_system_', _screenFader);
        }

        public function blackIn (duration:Number=0.33, startAlpha:Number=1):void { _screenFader.blackIn (duration, startAlpha); }
        public function blackOut(duration:Number=0.33, startAlpha:Number=0):void { _screenFader.blackOut(duration, startAlpha); }
        public function whiteIn (duration:Number=0.33, startAlpha:Number=1):void { _screenFader.whiteIn (duration, startAlpha); }
        public function whiteOut(duration:Number=0.33, startAlpha:Number=0):void { _screenFader.whiteOut(duration, startAlpha); }
        public function colorIn (color:uint, duration:Number=0.33, startAlpha:Number=1):void { _screenFader.colorIn (color, duration, startAlpha); }
        public function colorOut(color:uint, duration:Number=0.33, startAlpha:Number=0):void { _screenFader.colorOut(color, duration, startAlpha); }

        //------------------------------------------------------------
        // set enabled utilities
        //------------------------------------------------------------

        /**
         * layer の on/off を行う
         * off にすると時間が進まなくなり、タッチ不能になる。
         * ただし _system_ レイヤーには干渉できない
         */
        public function setEnabled(layerName:String, enabled:Boolean):Boolean {
            if (layerName == '_system_') { return false; }
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return false;
            }

            var targetLayer:StageLayer = _layers[layerName];
            if (enabled) {
                targetLayer.timeScale = 1.0;
                targetLayer.touchable = true;
            } else {
                targetLayer.timeScale = 0;
                targetLayer.touchable = false;
            }
            return true;
        }

        public function setEnabledTogether(layerNameList:Array, enabled:Boolean):void {
            for each (var layerName:String in layerNameList) {
                setEnabled(layerName, enabled);
            }
        }

        public function setEnabledOtherThan(excludeLayerNameList:Array, enabled:Boolean):void {
            for each (var layerName:String in _displayOrder) {
                // if the existing layer name is not contained in given layer name list,
                // apply setEnabled.
                if (excludeLayerNameList.indexOf(layerName)) {
                    setEnabled(layerName, enabled);
                }
            }
        }

        public function setAllLayersEnabled(enabled:Boolean):void {
            for each (var layerName:String in _displayOrder) {
                setEnabled(layerName, enabled);
            }
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _addLayer(scene:KrewScene, layerName:String, layer:StageLayer=null):void {
            if (layer == null) {
                layer = new StageLayer();
            }
            _layers[layerName] = layer;

            layer.layer     = layer;
            layer.layerName = layerName;
            scene.addLayer(layer);
            krew.fwlog('+++ add Layer: ' + layerName);
        }

        /**
         * グローバルレイヤーを新しい Scene に移し替えた際に、
         * グローバルな Actor の持つ Scene 依存の属性を設定し直す
         */
        private function _resetGlobalActorsContext(globalLayer:StageLayer):void {
            for each (var child:KrewActor in globalLayer.childActors) {
                child.applyForNewActor = globalLayer.applyForNewActor;
            }
        }
    }
}
