package com.tatsuyakoyama.krewfw.utility {

    //------------------------------------------------------------
    public class KrewPoint2D {

        public var x:Number;
        public var y:Number;

        //------------------------------------------------------------
        public function KrewPoint2D(x:Number=0, y:Number=0) {
            this.x = x;
            this.y = y;
        }

        public function addVectorWithScale(vector2D:KrewVector2D, scale:Number=1):void {
            x += vector2D.x * scale;
            y += vector2D.y * scale;
        }
    }
}
