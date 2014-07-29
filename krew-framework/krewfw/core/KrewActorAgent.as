package krewfw.core {

    import flash.media.Sound;
    import flash.utils.ByteArray;

    import starling.display.Image;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    import krewfw.core_internal.KrewSharedObjects;

    /**
     * Scene 上にのっていない Actor が Actor めいた仕事をしたいときの委譲先。
     * バックエンドに存在する各 Scene のシステム Actor に処理を代行してもらう。
     * 以下のように使う。
     *
     * <pre>
     *     import krewfw.utils.krew;
     *     krew.agent.sendMessage(...);
     * </pre>
     *
     * krewFramework は Actor の集まりで構成するという設計思想を持つが、
     * static な Model クラスなどがリソースへのアクセスやメッセージングなどを
     * 行いたくなった時、または Actor を増やした時のオーバヘッドを減らしたい場合などに利用する。
     *
     * ただしフレームワークのポリシー上、Actor にタスクを登録する系統のものは代行できない。
     * そういうことをしたくなったクラスは Actor として Scene 上に生きなければならない。
     */
    //------------------------------------------------------------
    public class KrewActorAgent {

        /** system actor on current scene */
        private static var _actor:KrewActor = null;

        //------------------------------------------------------------
        // Called by framework
        //------------------------------------------------------------

        public static function setSystemActor(actor:KrewActor):void {
            _actor = actor;
        }

        public static function clearSystemActor():void {
            _actor = null;
        }

        //------------------------------------------------------------
        // Singleton interface
        //------------------------------------------------------------

        private static var _instance:KrewActorAgent;

        public function KrewActorAgent() {
            if (_instance) {
                throw new Error("[KrewActorAgent] Cannot instantiate singleton.");
            }
        }

        public static function get instance():KrewActorAgent {
            if (_actor == null) {
                throw new Error("[KrewActorAgent] System actor is not ready.");
            }

            if (!_instance) {
                _instance = new KrewActorAgent();
            }
            return _instance;
        }

        //------------------------------------------------------------
        // Delegate methods
        //------------------------------------------------------------

        public function get sharedObj():KrewSharedObjects { return _actor.sharedObj; }

        public function getTexture     (fileName:String):Texture      { return _actor.getTexture     (fileName); }
        public function getTextureAtlas(fileName:String):TextureAtlas { return _actor.getTextureAtlas(fileName); }
        public function getImage       (fileName:String):Image        { return _actor.getImage       (fileName); }
        public function getSound       (fileName:String):Sound        { return _actor.getSound       (fileName); }
        public function getXml         (fileName:String):XML          { return _actor.getXml         (fileName); }
        public function getObject      (fileName:String):Object       { return _actor.getObject      (fileName); }
        public function getByteArray   (fileName:String):ByteArray    { return _actor.getByteArray   (fileName); }

        public function loadResources(fileNameList:Array, onLoadProgress:Function,
                                      onLoadComplete:Function):void
        {
            _actor.loadResources(fileNameList, onLoadProgress, onLoadComplete);
        }

        public function sendMessage(eventType:String, eventArgs:Object=null):void {
            _actor.sendMessage(eventType, eventArgs);
        }

        public function createActor(newActor:KrewActor, layerName:String):void {
            _actor.createActor(newActor, layerName);
        }

    }
}
