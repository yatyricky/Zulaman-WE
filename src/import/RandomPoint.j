//! zinc
library RandomPoint {
    public struct RandomPoint {
        static real x;
        static real y;
        static real angle;
        static real length;
        
        static method aroundUnit(unit u, real dis1, real dis2) {
            thistype.angle = GetRandomReal(0.0, 6.2832);
            thistype.length = GetRandomReal(dis1, dis2);
            thistype.x = GetUnitX(u) + Cos(thistype.angle) * thistype.length;
            thistype.y = GetUnitY(u) + Sin(thistype.angle) * thistype.length;
        }
    }
}
//! endzinc
