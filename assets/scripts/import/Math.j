//! zinc
library Math requires Vector {
    public struct Circle {
        public real x, y, r;

        method destroy() {
            this.deallocate();
        }

        static method create() -> thistype {
            thistype this = thistype.allocate();
            this.x = 0.0;
            this.y = 0.0;
            this.r = 1.0;
            return this;
        }
    }

    public struct Point {
        public real x, y;

        method destroy() {
            this.deallocate();
        }

        static method create() -> thistype {
            thistype this = thistype.allocate();
            this.x = 0.0;
            this.y = 0.0;
            return this;
        }

        static method new(real x, real y) -> thistype {
            thistype this = thistype.allocate();
            this.x = x;
            this.y = y;
            return this;
        }
    }

    public function IsPointInCircle(Point p, Circle c) -> boolean {
        return false;
    }

    public function MathCeil(real r) -> integer {
        integer i = R2I(r);
        if (I2R(i) == r) {
            return i;
        } else {
            return i + 1;
        }
    }

    public function MathFloor(real r) -> integer {
        return R2I(r);
    }

    public function DistancePointAndLineSegment(vector a, vector b, vector p) -> real {
        vector pa = vector.difference(a, p);
        vector ba = vector.difference(a, b);
        vector ab = vector.difference(b, a);
        vector pb = vector.difference(b, p);
        real pab = vector.getAngle(pa, ba);
        real pba = vector.getAngle(pb, ab);
        real dis;
        // print("pa="+pa.toString());
        // print("ba="+ba.toString());
        // print("ab="+ab.toString());
        // print("pb="+pb.toString());
        // print("pab="+R2S(pab));
        // print("pba="+R2S(pba));
        if (pab > bj_PI * 0.5) {
            dis = pa.getLength();
            pa.destroy();
            pb.destroy();
            ab.destroy();
            ba.destroy();
        } else if (pab > bj_PI * 0.5) {
            dis = pb.getLength();
            pa.destroy();
            pb.destroy();
            ab.destroy();
            ba.destroy();
        } else {
            pa.x = 0 - pa.x;
            pa.y = 0 - pa.y;
            pa.z = 0 - pa.z;
            dis = RAbsBJ(ab.y * pa.x - ab.x * pa.y) / ab.getLength();
            pa.destroy();
            pb.destroy();
            ab.destroy();
            ba.destroy();
        }
        return dis;
    }

    public function IsPointInLinearShooter(real mx, real my, real ox, real oy, real angle, real width, real distance) -> boolean {
        real angleOffset = angle - bj_PI * 0.5;
        real refOffX = Cos(angleOffset) * width * 0.5;
        real refOffY = Sin(angleOffset) * width * 0.5;
        real ax = ox + refOffX;
        real ay = oy + refOffY;
        real abx = Cos(angle) * distance + ox + refOffX - ax;
        real aby = Sin(angle) * distance + oy + refOffY - ay;
        real adx = ox - refOffX - ax;
        real ady = oy - refOffY - ay;
        real amx = mx - ax;
        real amy = my - ay;
        real magAB = SquareRoot(abx * abx + aby * aby);
        real magAD = SquareRoot(adx * adx + ady * ady);
        real projAMonAB = (amx * abx + amy * aby) / magAB;
        real projAMonAD = (amx * adx + amy * ady) / magAD;
        return (projAMonAB >= 0 && projAMonAB <= magAB && projAMonAD >= 0 && projAMonAD <= magAD);
    }

    // https://jsfiddle.net/PerroAZUL/zdaY8/1/
    public function IsPointInTriangle(real px, real py, real p0x, real p0y, real p1x, real p1y, real p2x, real p2y) -> boolean {
        real A = 0.5 * (-p1y * p2x + p0y * (-p1x + p2x) + p0x * (p1y - p2y) + p1x * p2y);
        real sign = 1;
        real s, t;
        if (A < 0) {sign = -1;}
        s = (p0y * p2x - p0x * p2y + (p2y - p0y) * px + (p0x - p2x) * py) * sign;
        t = (p0x * p1y - p0y * p1x + (p0y - p1y) * px + (p1x - p0x) * py) * sign;
        return ((s > 0) && (t > 0) && ((s + t) < 2 * A * sign));
    }

    public function AngleBetweenAngles(real b, real a) -> real {
        real d = ModuloReal(RAbsBJ(a - b), bj_PI * 2);
        real sign = -1; 
        real r = d;
        if (d > bj_PI) {
            r = bj_PI * 2 - d;
        }
        if ((a - b >= 0 && a - b <= bj_PI) || (a - b <= -1.0 * bj_PI && a - b >= -2 * bj_PI)) {
            sign = 1;
        }
        r *= sign;
        return r;
    }

}
//! endzinc
