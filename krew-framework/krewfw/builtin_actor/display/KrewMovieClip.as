package krewfw.builtin_actor.display {

    import starling.display.Image;

    import krewfw.core.KrewActor;

    //------------------------------------------------------------
    public class KrewMovieClip extends KrewActor {

        protected var _movieImage:Image;

        private var _movieInfoList:Array = null;
        private var _frameCount:int       = 0;
        private var _framePlayTime:Number = 0;

        //------------------------------------------------------------
        public function KrewMovieClip() {}

        /**
         * Set up frame animation info.
         * Please call after init().
         *
         * @param infoList List of [imageName, durationSec]. Example:
         * <pre>
         * [
         *     ['frame_1', 0.1],
         *     ['frame_2', 0.1],
         *     ['frame_3', 0.1],
         *     ...
         * ]
         * </pre>
         */
        public function setUpMovieClip(infoList:Array, width:Number, height:Number,
                                       x:Number=0, y:Number=0):void
        {
            _movieInfoList = infoList;

            var imageName:String = _movieInfoList[0][0];
            _movieImage = getImage(imageName);
            addImage(_movieImage, width, height, x, y);
            _frameCount = 0;
        }

        public function changeClip(newInfoList:Array):void {
            _movieInfoList = newInfoList;

            _frameCount    = 0;
            _framePlayTime = 0;

            var imageName:String = _movieInfoList[_frameCount][0];
            changeImage(_movieImage, imageName);
        }

        public function setRandomFrame():void {
            if (!_movieInfoList) { return; }
            if (_movieInfoList.length == 0) { return; }

            _frameCount = krew.randInt(_movieInfoList.length);
        }

        public override function update(passedTime:Number):void {
            super.update(passedTime);
            _updateMovieFrame(passedTime);
        }

        private function _updateMovieFrame(passedTime:Number):void {
            if (!_movieInfoList) { return; }
            if (_movieInfoList.length <= 1) { return; }

            var nextDuration:Number = _movieInfoList[_frameCount][1];
            _framePlayTime += passedTime;

            if (_framePlayTime > nextDuration) {
                _framePlayTime -= nextDuration;
                ++_frameCount;
                if (_frameCount >= _movieInfoList.length) { _frameCount = 0; }

                var imageName:String = _movieInfoList[_frameCount][0];
                changeImage(_movieImage, imageName);
            }
        }

    }
}
