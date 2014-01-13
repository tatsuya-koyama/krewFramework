package krewfw.core_internal {

    import flash.utils.Dictionary;

    import starling.display.DisplayObject;

    import krewfw.builtin_actor.display.ScreenFader;
    import krewfw.utils.krew;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewScene;

    //------------------------------------------------------------
    public class StageLayerManager {

        private var _layers:Dictionary = new Dictionary;
        private var _displayOrder:Array;
        private var _screenFader:ScreenFader;

        //------------------------------------------------------------
        public function StageLayerManager() {}

        /**
         * displayOrder で指定したレイヤー名の順に奥から並ぶ.
         * 例えば ['back', 'middle', 'front'] を渡すと back レイヤーが一番奥になる。
         * そして暗黙で最前面に '_system_' レイヤーが足されるので
         * _system_ という名前は使わないように注意
         */
        public function setUpLayers(scene:KrewScene, displayOrder:Array):void {
            displayOrder.push('_system_');
            for each (var layerName:String in displayOrder) {
                _addLayer(scene, layerName);
            }
            _displayOrder = displayOrder;

            _setUpScreenFader();
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

        public function dispose():void {
            _removeAllLayers();
        }

        private function _addLayer(scene:KrewScene, layerName:String):void {
            var layer:StageLayer = new StageLayer();
            _layers[layerName] = layer;

            layer.layer     = layer
            layer.layerName = layerName;
            scene.addLayer(layer);
            krew.fwlog('+++ addLayer: ' + layerName);
        }

        private function _removeAllLayers():void {
            for (var layerName:String in _layers) {
                _layers[layerName].dispose();
                delete _layers[layerName];
            }
            _displayOrder = new Array(); // clear array
            krew.fwlog('--- removeAllLayers');
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

        public function getLayer(layerName:String):StageLayer {
            if (!_layers[layerName]) {
                krew.fwlog('[Error] layer not found: ' + layerName);
                return null;
            }

            return _layers[layerName];
        }

        public function onUpdate(passedTime:Number):void {
            // update layers in display order
            for each (var layerName:String in _displayOrder) {
                _layers[layerName].onUpdate(passedTime);
            }
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
    }
}
