package krewdemo.actor.world_test {

    import flash.geom.Rectangle;

    import starling.display.DisplayObject;
    import starling.display.Sprite;

    import krewfw.core.KrewActor;
    import krewfw.utils.krew;

    // debug -----------
    import starling.display.Image;
    import krewfw.core.KrewBlendMode;
    //------------------

    /**
     * Loose QuadTree で空間分割し Culling を行う Sprite.
     * Tree の再構築のための最適化などは行っていないため、
     * static なマップのオブジェクトなどを事前に登録しておくような利用を想定。
     */
    //------------------------------------------------------------
    public class QuadTreeSprite extends Sprite {

        /**
         * 子 Node の重なりをどれくらいにするか。
         * m としたとき子ノードは 0.5 * (1+m) のサイズになる
         */
        private var _subNodeMargin:Number = 0.2;
        private var _scaleConvergence:Number;

        private var _northWest:QuadTreeSprite = null;
        private var _northEast:QuadTreeSprite = null;
        private var _southWest:QuadTreeSprite = null;
        private var _southEast:QuadTreeSprite = null;

        private var _centerX:Number;
        private var _centerY:Number;
        private var _halfWidth:Number;
        private var _halfHeight:Number;

        private var _depthLevel:int;
        private var _maxDepth:int;

        private var _displayObjList:Vector.<DisplayObject> = null;
        private var _actorList:Vector.<KrewActor> = null;

        // debug view
        private var _debugRect:Image = null;

        // debug info
        public static var stat_countActorUpdate:int;

        //------------------------------------------------------------
        public function QuadTreeSprite(width:Number, height:Number,
                                       centerX:Number=0, centerY:Number=0,
                                       depthLevel:int=0, maxDepth:int=6,
                                       subNodeMargin:Number=0.25)
        {
            _halfWidth  = width  / 2;
            _halfHeight = height / 2;
            _centerX    = centerX;
            _centerY    = centerY;

            _depthLevel = depthLevel;
            _maxDepth   = maxDepth;

            _subNodeMargin = subNodeMargin;
            _scaleConvergence = _getTreeScaleConvergence(_subNodeMargin);

            // debug display ---------------
            var image:Image = krew.agent.getImage("debug_rect");
            image.blendMode = KrewBlendMode.MULTIPLY;
            image.color     = 0x55aa00;
            image.alpha     = 0.09;
            image.width     = width;
            image.height    = height;
            image.x         = centerX - _halfWidth;
            image.y         = centerY - _halfHeight;
            addChild(image);
            _debugRect = image;
            //------------------------------
        }

        //------------------------------------------------------------
        // public
        //------------------------------------------------------------

        public function addDisplayObj(dispObj:DisplayObject,
                                      objWidth:Number=NaN, objHeight:Number=NaN):void
        {
            addActor(dispObj, objWidth, objHeight);
        }

        /**
         * Actor を QuadTree に登録する。width, height で示された Actor の AABB が
         * 子 Node に完全に収まるなら、子 Node に降ろしていく。
         * width, height 未指定の場合は Actor の getter を呼ぶが、
         * これはそれなりに計算コストがかかるので注意。
         *
         * [Note] Actor の x, y 座標は AABB の中央にあることを想定している。
         */
        public function addActor(actor:DisplayObject,
                                 actorWidth:Number=NaN, actorHeight:Number=NaN):void
        {
            // [Note] In Starling's Sprite, costs of width / height are too expensive.
            //        You should give values manually.
            if (isNaN(actorWidth )) { actorWidth  = actor.width; }
            if (isNaN(actorHeight)) { actorHeight = actor.height; }

            // 自身が深さの limit に達しているなら自身に addChild
            if (_depthLevel == _maxDepth) {
                _addActorOrDisplayObj(actor);
                return;
            }

            var mw:Number  = _halfWidth  * _subNodeMargin;
            var mh:Number  = _halfHeight * _subNodeMargin;
            var qhw:Number = _halfWidth ;  // half width  of QuadTree node
            var qhh:Number = _halfHeight;  // half height of QuadTree node
            var ahw:Number = actorWidth  / 2;  // actor's half width
            var ahh:Number = actorHeight / 2;  // actor's half height

            // 左上の子 Node に収まるか
            if (_centerX - qhw - mw < actor.x - ahw  &&  actor.x + ahw < _centerX + mw  &&
                _centerY - qhh - mh < actor.y - ahh  &&  actor.y + ahh < _centerY + mh) {

                _addActorToNorthWest(actor, actorWidth, actorHeight);
                return;
            }

            // 右上の子 Node に収まるか
            if (_centerX - mw < actor.x - ahw  &&  actor.x + ahw < _centerX + qhw + mw  &&
                _centerY - qhh - mh < actor.y - ahh  &&  actor.y + ahh < _centerY + mh) {

                _addActorToNorthEast(actor, actorWidth, actorHeight);
                return;
            }

            // 左下の子 Node に収まるか
            if (_centerX - qhw - mw < actor.x - ahw  &&  actor.x + ahw < _centerX + mw  &&
                _centerY - mh < actor.y - ahh  &&  actor.y + ahh < _centerY + qhh + mh) {

                _addActorToSouthWest(actor, actorWidth, actorHeight);
                return;
            }

            // 右下の子 Node に収まるか
            if (_centerX - mw < actor.x - ahw  &&  actor.x + ahw < _centerX + qhw + mw  &&
                _centerY - mh < actor.y - ahh  &&  actor.y + ahh < _centerY + qhh + mh) {

                _addActorToSouthEast(actor, actorWidth, actorHeight);
                return;
            }

            // 子 Node には収まらなかったので自身に足す
            _addActorOrDisplayObj(actor);
        }

        public function updateVisibility(viewport:Rectangle):void {
            if (!_intersectsWith(viewport)) {
                visible = false;
                return;
            }

            visible = true;

            //visible = (_depthLevel <= 6);
            //if (!visible) { return; }

            if (_northWest) { _northWest.updateVisibility(viewport); }
            if (_northEast) { _northEast.updateVisibility(viewport); }
            if (_southWest) { _southWest.updateVisibility(viewport); }
            if (_southEast) { _southEast.updateVisibility(viewport); }
        }

        public function updateActors(passedTime:Number):void {
            if (!visible) { return; }

            for each (var actor:KrewActor in _actorList) {
                actor.onUpdate(passedTime);
                ++stat_countActorUpdate;
            }

            if (_northWest) { _northWest.updateActors(passedTime); }
            if (_northEast) { _northEast.updateActors(passedTime); }
            if (_southWest) { _southWest.updateActors(passedTime); }
            if (_southEast) { _southEast.updateActors(passedTime); }
        }

        //------------------------------------------------------------
        // debug
        //------------------------------------------------------------

        public function startRecDebugStat():void {
            stat_countActorUpdate = 0;
        }

        public function setDebugRectVisible(visible:Boolean):void {
            if (_debugRect) {
                _debugRect.visible = visible;
            }

            if (_northWest) { _northWest.setDebugRectVisible(visible); }
            if (_northEast) { _northEast.setDebugRectVisible(visible); }
            if (_southWest) { _southWest.setDebugRectVisible(visible); }
            if (_southEast) { _southEast.setDebugRectVisible(visible); }
        }

        //------------------------------------------------------------
        // private
        //------------------------------------------------------------

        private function _addActorOrDisplayObj(obj:DisplayObject):void {
            if (obj is KrewActor) {
                _addActor(obj as KrewActor);
            }
            else {
                _addDisplayObj(obj);
            }
        }

        private function _addActor(actor:KrewActor):void {
            if (!_actorList) {
                _actorList = new Vector.<KrewActor>();
            }
            _actorList.push(actor);

            addChild(actor);
        }

        public function _addDisplayObj(dispObj:DisplayObject):void {
            if (!_displayObjList) {
                _displayObjList = new Vector.<DisplayObject>();
            }
            _displayObjList.push(dispObj);

            addChild(dispObj);
        }

        private function _addActorToNorthWest(actor:DisplayObject,
                                              actorWidth:Number, actorHeight:Number):void
        {
            if (!_northWest) {
                _northWest = new QuadTreeSprite(
                    _halfWidth * _subNodeScale, _halfHeight * _subNodeScale,
                    _centerX - (_halfWidth  / 2),
                    _centerY - (_halfHeight / 2),
                    _depthLevel + 1, _maxDepth, _subNodeMargin
                );
                addChild(_northWest);
            }
            _northWest.addActor(actor, actorWidth, actorHeight);
        }

        private function _addActorToNorthEast(actor:DisplayObject,
                                              actorWidth:Number, actorHeight:Number):void
        {
            if (!_northEast) {
                _northEast = new QuadTreeSprite(
                    _halfWidth * _subNodeScale, _halfHeight * _subNodeScale,
                    _centerX + (_halfWidth  / 2),
                    _centerY - (_halfHeight / 2),
                    _depthLevel + 1, _maxDepth, _subNodeMargin
                );
                addChild(_northEast);
            }
            _northEast.addActor(actor, actorWidth, actorHeight);
        }

        private function _addActorToSouthWest(actor:DisplayObject,
                                              actorWidth:Number, actorHeight:Number):void
        {
            if (!_southWest) {
                _southWest = new QuadTreeSprite(
                    _halfWidth * _subNodeScale, _halfHeight * _subNodeScale,
                    _centerX - (_halfWidth  / 2),
                    _centerY + (_halfHeight / 2),
                    _depthLevel + 1, _maxDepth, _subNodeMargin
                );
                addChild(_southWest);
            }
            _southWest.addActor(actor, actorWidth, actorHeight);
        }

        private function _addActorToSouthEast(actor:DisplayObject,
                                              actorWidth:Number, actorHeight:Number):void
        {
            if (!_southEast) {
                _southEast = new QuadTreeSprite(
                    _halfWidth * _subNodeScale, _halfHeight * _subNodeScale,
                    _centerX + (_halfWidth  / 2),
                    _centerY + (_halfHeight / 2),
                    _depthLevel + 1, _maxDepth, _subNodeMargin
                );
                addChild(_southEast);
            }
            _southEast.addActor(actor, actorWidth, actorHeight);
        }

        private function get _subNodeScale():Number {
            return (1 + _subNodeMargin);
        }

        /**
         * 子 Node のサイズが親 Node サイズの 0.5 * (1 + margin) であるとき、
         * 深さを無限にしたときに QuadTree 全体のサイズがいくらに収束するかを返す。
         *
         * Note: これは等比数列 a, ar, ar^2, ar^3, ...  で
         *           a = margin / 2
         *           r = (1 + margin) / 2
         *       としたときの無限級数の収束値として求められる。
         */
        private function _getTreeScaleConvergence(margin:Number):Number {
            return 1 + (margin / (1 - margin));
        }

        private function _intersectsWith(rect:Rectangle):Boolean {
            var nodeWidth :Number = _halfWidth  * _scaleConvergence;
            var nodeHeight:Number = _halfHeight * _scaleConvergence;
            if (_centerX - nodeWidth  < rect.right   &&  rect.left < _centerX + nodeWidth  &&
                _centerY - nodeHeight < rect.bottom  &&  rect.top  < _centerY + nodeHeight) {

                return true;
            }
            return false;
        }

    }
}
