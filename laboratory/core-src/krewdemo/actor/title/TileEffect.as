package krewdemo.actor.title {

    import krewfw.builtin_actor.display.SimpleImageActor;
    import krewfw.core.KrewActor;
    import krewfw.core.KrewBlendMode;
    import krewfw.core.KrewTransition;

    //------------------------------------------------------------
    public class TileEffect extends KrewActor {

        private var _tiles:Array = [];

        private static const TILE_SIZE:int = 40;
        private static const TILE_COL :int = 12;
        private static const TILE_ROW :int =  8;

        private static const DELAY_RADIAL       :int = 1;
        private static const DELAY_LEFT_2_RIGHT :int = 2;
        private static const DELAY_RIGHT_2_LEFT :int = 3;
        private static const DELAY_UPPER_2_LOWER:int = 4;
        private static const DELAY_LOWER_2_UPPER:int = 5;
        private static const DELAY_RANDOM       :int = 6;

        private static const ANIM_CHANGE_SCALE       :int = 1;
        private static const ANIM_CHANGE_SCALE_RANDOM:int = 2;
        private static const ANIM_CHANGE_RANDOM_SWING:int = 3;
        private static const ANIM_CHANGE_SCALE_SLOW  :int = 4;
        private static const ANIM_CHANGE_SCALE_SWING :int = 5;
        private static const ANIM_ROTATE             :int = 6;
        private static const ANIM_ROTATE_AND_BIG     :int = 7;
        private static const ANIM_BLINK              :int = 8;
        private static const ANIM_BLINK2             :int = 9;
        private static const ANIM_MOVE               :int = 10;
        private static const ANIM_MOVE_DYNAMIC       :int = 11;

        //------------------------------------------------------------
        public override function init():void {
            for (var row:int = 0;  row < TILE_ROW;  ++row) {
                for (var col:int = 0;  col < TILE_COL;  ++col) {

                    var tile:Tile = new Tile(
                        "white", TILE_SIZE, TILE_SIZE,
                        (col * TILE_SIZE) + (TILE_SIZE / 2),
                        (row * TILE_SIZE) + (TILE_SIZE / 2)
                    );
                    tile.scaleX = tile.scaleY = 0.95;
                    tile.alpha = 0.6;

                    addActor(tile);
                    _tiles.push(tile);
                }
            }

            addPeriodicTask(1.3, _attachRandomAnimation);
            _attachRandomAnimation();
        }

        private function _getTile(col:int, row:int):Tile {
            return _tiles[(row * TILE_COL) + col];
        }

        private function _getDelay(pattern:int, col:int, row:int):Number {
            var distance:Number;

            switch (pattern) {
            case DELAY_RADIAL:
                distance = krew.distance((TILE_COL - 1) / 2, (TILE_ROW - 1) / 2, col, row);
                return (distance * 0.09);
                break;

            case DELAY_LEFT_2_RIGHT:
                distance = krew.distance(0, row, col, row);
                return (distance * 0.055);
                break;

            case DELAY_RIGHT_2_LEFT:
                distance = krew.distance(TILE_COL, row, col, row);
                return (distance * 0.055);
                break;

            case DELAY_UPPER_2_LOWER:
                distance = krew.distance(col, 0, col, row);
                return (distance * 0.075);
                break;

            case DELAY_LOWER_2_UPPER:
                distance = krew.distance(col, TILE_ROW, col, row);
                return (distance * 0.075);
                break;

            case DELAY_RANDOM:
                return krew.rand(0, 1.0);
                break;
            }

            return 0;
        }

        private function _attachAnimation(actor:Tile, pattern:int,
                                          param:Number, delay:Number):void
        {
            switch (pattern) {
            case ANIM_CHANGE_SCALE:
                param = (param * 0.7) + 0.3;
                actor.act().wait(delay).scaleTo(0.3, param, param, KrewTransition.SWING);
                break;

            case ANIM_CHANGE_SCALE_RANDOM:
                var targetScale:Number = krew.rand(0.3, 1.0);
                actor.act().wait(delay).scaleTo(0.3, targetScale, targetScale, KrewTransition.SWING);
                break;

            case ANIM_CHANGE_RANDOM_SWING:
                var targetScale:Number = krew.rand(0.3, 1.0);
                actor.act().wait(delay).scaleTo(1.0, targetScale, targetScale, KrewTransition.SWING);
                break;

            case ANIM_CHANGE_SCALE_SLOW:
                param = (param * 0.7) + 0.3;
                actor.act().wait(delay).scaleToEaseIn(1.0, param, param);
                break;

            case ANIM_CHANGE_SCALE_SWING:
                param = (param * 0.7) + 0.3;
                actor.act().wait(delay).scaleTo(1.0, param, param, KrewTransition.SWING);
                break;

            case ANIM_ROTATE:
                actor.act().wait(delay).rotate(0.5, 90).rotateTo(0, 0);
                break;

            case ANIM_ROTATE_AND_BIG:
                actor.act().wait(delay).rotate(0.3, 90).rotate(0.3, 90).rotateTo(0, 0);
                actor.act().wait(delay).scaleTo(0.3, 0.1, 0.1).scaleTo(0.3, 0.9, 0.9);
                break;

            case ANIM_BLINK:
                actor.act().wait(delay).alphaTo(0.2, 0).alphaTo(0.2, 1).alphaTo(0.2, 0.6);
                break;

            case ANIM_BLINK2:
                actor.act().wait(delay).alphaTo(0.4, 0).alphaTo(0.4, 1);
                actor.act().wait(delay)
                    .scaleTo(0.4, 1.0, 1.0)
                    .scaleTo(0, 0, 0)
                    .scaleTo(0.4, 0.9, 0.9);
                break;

            case ANIM_MOVE:
                actor.act().wait(delay)
                    .moveEaseIn (0.15,  10,   0)
                    .moveEaseOut(0.15,   0,  10)
                    .moveEaseIn (0.15, -10,   0)
                    .moveEaseOut(0.15,   0, -10)
                    .moveTo(0, actor.homeX, actor.homeY);
                break;

            case ANIM_MOVE_DYNAMIC:
                var targetX:Number = krew.rand(actor.homeX - 100, actor.homeX + 100);
                var targetY:Number = krew.rand(actor.homeY - 100, actor.homeY + 100);
                actor.act().wait(delay)
                    .moveToEaseOut(0.4, targetX, targetY)
                    .moveToEaseIn (0.4, actor.homeX, actor.homeY);
                break;
            }
        }

        private function _attachRandomAnimation():void {
            var delayPattern:int = krew.randInt(1, 6);
            var animPattern :int = krew.randInt(1, 11);
            var animParam:Number = krew.rand(0, 1.0);

            for (var row:int = 0;  row < TILE_ROW;  ++row) {
                for (var col:int = 0;  col < TILE_COL;  ++col) {

                    var delay:Number = _getDelay(delayPattern, col, row);
                    var tile:Tile    = _getTile(col, row);
                    _attachAnimation(tile, animPattern, animParam, delay);
                }
            }
        }

    }
}
