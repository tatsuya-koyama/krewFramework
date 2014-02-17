package krewfw.core {

    import flash.media.Sound;
    import flash.utils.Dictionary;

    import starling.display.Image;
    import starling.display.Sprite;
    import starling.textures.Texture;

    import krewfw.core_internal.IdGenerator;
    import krewfw.core_internal.KrewSharedObjects;
    import krewfw.core_internal.StageLayer;
    import krewfw.core_internal.collision.CollisionShape;
    import krewfw.utils.swiss_knife.KrewTopUtil;

    //------------------------------------------------------------
    public class KrewGameObject extends Sprite {

        private var _id:int = 0;
        private var _sharedObj:KrewSharedObjects;
        private var _listeningEventTypes:Dictionary = new Dictionary();

        //------------------------------------------------------------
        public function get id():int {
            return _id;
        }

        public function get sharedObj():KrewSharedObjects {
            return _sharedObj;
        }

        public function set sharedObj(sharedObj:KrewSharedObjects):void {
            _sharedObj = sharedObj;
        }

        /**
         * よく使う utility への簡易アクセス
         */
        public function get krew():KrewTopUtil {
            return KrewTopUtil.instance;
        }

        //------------------------------------------------------------
        public function KrewGameObject() {
            _id = IdGenerator.generateId();
            touchable = false;
        }

        public override function dispose():void {
            stopAllListening();
            super.dispose();
        }

        /**
         * この時点で sharedObj がセットされているので
         * resourceManager にアクセスできる
         */
        public function init():void {
            // Override this.
        }

        protected function onDispose():void {
            // Override this.
        }

        public function onUpdate(passedTime:Number):void {
            // Override this.
        }

        //------------------------------------------------------------
        // Shortcut for SharedObj
        //------------------------------------------------------------

        //----- Resource Accessor

        public function getTexture(fileName:String):Texture { return sharedObj.resourceManager.getTexture(fileName); }
        public function getImage  (fileName:String):Image   { return sharedObj.resourceManager.getImage  (fileName); }
        public function getSound  (fileName:String):Sound   { return sharedObj.resourceManager.getSound  (fileName); }
        public function getXml    (fileName:String):XML     { return sharedObj.resourceManager.getXml    (fileName); }
        public function getObject (fileName:String):Object  { return sharedObj.resourceManager.getObject (fileName); }

        //----- Sound Control

        /**
         * 同じ bgmId をすでに再生中の場合は、再生し直さない。
         * （0 から再生し直したい場合は先に stopBgm() を呼んでね）
         */
        public function playBgm(bgmId:String, vol:Number=NaN, startTime:Number=0):void {
            var bgm:Sound = getSound(bgmId);
            sharedObj.soundPlayer.playBgm(bgm, bgmId, vol, startTime);
        }

        public function pauseBgm():void {
            sharedObj.soundPlayer.pauseBgm();
        }

        public function resumeBgm():void {
            sharedObj.soundPlayer.resumeBgm();
        }

        public function stopBgm():void {
            sharedObj.soundPlayer.stopBgm();
        }

        public function playSe(seId:String, pan:Number=0, loops:int=0,
                               vol:Number=NaN, startTime:Number=0):void
        {
            var se:Sound = getSound(seId);
            sharedObj.soundPlayer.playSe(se, pan, loops, vol, startTime);
        }

        public function stopSe():void {
            sharedObj.soundPlayer.stopSe();
        }

        public function stopAllSound():void {
            sharedObj.soundPlayer.stopAll();
        }

        //----- Layer Control

        public function getLayer(layerName:String):StageLayer {
            return sharedObj.layerManager.getLayer(layerName);
        }

        public function setTimeScale(layerName:String, timeScale:Number):void {
            sharedObj.layerManager.setTimeScale(layerName, timeScale);
        }

        public function resetTimeScale(layerName:String):void {
            sharedObj.layerManager.resetTimeScale(layerName);
        }

        public function setLayerEnabled(layerNameList:Array, enabled:Boolean):void {
            sharedObj.layerManager.setEnabledTogether(layerNameList, enabled);
        }

        public function setLayerEnabledOtherThan(excludeLayerNameList:Array, enabled:Boolean):void {
            sharedObj.layerManager.setEnabledOtherThan(excludeLayerNameList, enabled);
        }

        public function setAllLayersEnabled(enabled:Boolean):void {
            sharedObj.layerManager.setAllLayersEnabled(enabled);
        }

        //----- Collision

        public function setCollision(groupName:String, shape:CollisionShape):void {
            sharedObj.collisionSystem.addShape(groupName, shape);
        }

        //------------------------------------------------------------
        // Fade In/Out Helper
        //------------------------------------------------------------
        public function blackIn (duration:Number=0.33, startAlpha:Number=1):void { sharedObj.layerManager.blackIn (duration, startAlpha); }
        public function blackOut(duration:Number=0.33, startAlpha:Number=0):void { sharedObj.layerManager.blackOut(duration, startAlpha); }
        public function whiteIn (duration:Number=0.33, startAlpha:Number=1):void { sharedObj.layerManager.whiteIn (duration, startAlpha); }
        public function whiteOut(duration:Number=0.33, startAlpha:Number=0):void { sharedObj.layerManager.whiteOut(duration, startAlpha); }
        public function colorIn (color:uint, duration:Number=0.33, startAlpha:Number=1):void { sharedObj.layerManager.colorIn (color, duration, startAlpha); }
        public function colorOut(color:uint, duration:Number=0.33, startAlpha:Number=0):void { sharedObj.layerManager.colorOut(color, duration, startAlpha); }

        //------------------------------------------------------------
        // Messaging
        //------------------------------------------------------------
        public function listen(eventType:String, callback:Function):void {
            sharedObj.notificationService.addListener(
                this, eventType, callback
            );
            _listeningEventTypes[eventType] = true;
        }

        public function stopListening(eventType:String):void {
            sharedObj.notificationService.removeListener(
                this, eventType
            );
            delete _listeningEventTypes[eventType];
        }

        public function stopAllListening():void {
            for (var eventType:String in _listeningEventTypes) {
                stopListening(eventType);
            }
        }

        public function sendMessage(eventType:String, eventArgs:Object=null):void {
            sharedObj.notificationService.postMessage(
                eventType, eventArgs
            );
        }
    }
}
