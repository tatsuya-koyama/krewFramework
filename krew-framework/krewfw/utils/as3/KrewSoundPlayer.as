package krewfw.utils.as3 {

    import flash.events.Event;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.utils.getDefinitionByName;

    import krewfw.KrewConfig;
    import krewfw.utils.krew;

    public class KrewSoundPlayer {

        private var _bgmChannel:SoundChannel;
        private var _seChannel :SoundChannel;

        private var _soundTransform:SoundTransform;
        private var _bgmVolume:Number = 1.0;  // master volume for BGM
        private var _seVolume:Number  = 1.0;  // master volume for SE

        private var _currentBgmId:String;
        private var _currentBgm:Sound;
        private var _pausePosition:int = 0;


        /**
         * BGM と SE の再生ユーティリティー。
         * ToDo: 現状は非常にシンプルなもの。BGM は全てループ再生
         * ToDO: 同じ SE 鳴らし過ぎちゃわない対応
         */
        //------------------------------------------------------------
        public function KrewSoundPlayer() {
            _soundTransform = new SoundTransform();

            _followDeviceMuteButton();
        }

        //------------------------------------------------------------
        // accessors
        //------------------------------------------------------------

        public function get bgmVolume():Number { return _bgmVolume; }

        public function set bgmVolume(vol:Number):void {
            _bgmVolume = vol;
            _bgmVolume = krew.within(_bgmVolume, 0, 1);
        }

        public function get seVolume():Number { return _seVolume; }

        public function set seVolume(vol:Number):void {
            _seVolume = vol;
            _seVolume = krew.within(_seVolume, 0, 1);
        }

        //------------------------------------------------------------
        // interfaces for BGM
        //------------------------------------------------------------

        /**
         * 渡した Sound を BGM として再生。
         * 前回渡した bgmId と同じものをすでに再生中の場合は、再生し直しを行わない。
         * bgmId に null を渡した場合は常に再生し直す
         */
        public function playBgm(sound:Sound, bgmId:String=null, vol:Number=NaN, startTime:Number=0):void
        {
            if (_bgmChannel) {
                if (bgmId != null  &&  bgmId == _currentBgmId) { return; }
                _disposeBgmChannel();
            }
            _currentBgmId = bgmId;

            _soundTransform.volume = (!isNaN(vol)) ? vol : _bgmVolume;
            var loops:int = 1;
            _bgmChannel = sound.play(startTime, loops, _soundTransform);
            _currentBgm = sound;

            _bgmChannel.addEventListener(Event.SOUND_COMPLETE, _onBgmComplete);
        }

        public function replayBgm(vol:Number=NaN, startTime:Number=0):void {
            if (!_currentBgm) { return; }

            _currentBgmId = null;
            playBgm(_currentBgm, _currentBgmId, vol, startTime);
        }

        public function pauseBgm():void {
            if (!_bgmChannel) { return; }

            _pausePosition = _bgmChannel.position;
            _bgmChannel.stop();
        }

        public function resumeBgm():void {
            if (!_bgmChannel) { return; }

            stopBgm();
            playBgm(_currentBgm, _currentBgmId, NaN, _pausePosition);
        }

        public function stopBgm():void {
            if (!_bgmChannel) { return; }

            _disposeBgmChannel();
        }

        //------------------------------------------------------------
        // interfaces for SE
        //------------------------------------------------------------

        public function playSe(sound:Sound, pan:Number=0, loops:int=0,
                               vol:Number=NaN, startTime:Number=0):void
        {
            _soundTransform.pan    = pan;
            _soundTransform.volume = (!isNaN(vol)) ? vol : _seVolume;
            _seChannel = sound.play(startTime, loops, _soundTransform);
        }

        public function stopSe():void {
            if (_seChannel) {
                _seChannel.stop();
                _seChannel = null;
            }
        }

        //------------------------------------------------------------
        // interfaces for Entire Sound
        //------------------------------------------------------------

        public function stopAll():void {
            stopBgm();
            stopSe();
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        /**
         * 端末のミュートボタンに従う。IS_AIR が true にセットされていなければ何もしない。
         * クラスを動的に取得しているのは Flash にこのクラスが無いため
         */
        private function _followDeviceMuteButton():void {
            if (!KrewConfig.IS_AIR) { return; }

            var AudioPlaybackMode:Class  = getDefinitionByName("flash.media.AudioPlaybackMode") as Class;
            SoundMixer.audioPlaybackMode = AudioPlaybackMode.AMBIENT;
        }

        /**
         * pause & resume してしまうと、Sound.play() の loops に 2 以上の値を入れて
         * ループさせた場合に、resume した位置から再生が再開されてしまうようだ。
         * ひとまず再生終了のコールバックで 0 位置から再生し直すことでループ再生する
         */
        private function _onBgmComplete(event:Event):void {
            replayBgm();
        }

        private function _disposeBgmChannel():void {
            if (!_bgmChannel) { return; }

            _bgmChannel.stop();
            _bgmChannel.removeEventListener(Event.SOUND_COMPLETE, _onBgmComplete);
            _bgmChannel = null;
        }

    }
}
