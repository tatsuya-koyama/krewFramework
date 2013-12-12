package com.tatsuyakoyama.krewfw.core_internal {

    import com.tatsuyakoyama.krewfw.utility.KrewSoundPlayer;

    //------------------------------------------------------------
    public class KrewSharedObjects {

        private var _resourceManager:KrewResourceManager;
        private var _layerManager:StageLayerManager;
        private var _notificationService:NotificationService;
        private var _collisionSystem:CollisionSystem;
        private var _soundPlayer:KrewSoundPlayer;

        //------------------------------------------------------------
        public function get resourceManager():KrewResourceManager {
            return _resourceManager;
        }

        public function get layerManager():StageLayerManager {
            return _layerManager;
        }

        public function get notificationService():NotificationService {
            return _notificationService;
        }

        public function get collisionSystem():CollisionSystem {
            return _collisionSystem;
        }

        public function get soundPlayer():KrewSoundPlayer {
            return _soundPlayer;
        }

        //------------------------------------------------------------
        public function KrewSharedObjects() {
            _resourceManager     = new KrewResourceManager();
            _layerManager        = new StageLayerManager();
            _notificationService = new NotificationService();
            _collisionSystem     = new CollisionSystem();
            _soundPlayer         = new KrewSoundPlayer();
        }
    }
}
