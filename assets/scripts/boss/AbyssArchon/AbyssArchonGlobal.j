//! zinc
library AbyssArchonGlobal {

    //! runtextmacro WriteArrayList("SummonedWraiths", "unit", "null")

    public struct AbyssArchonGlobal {
        private static boolean flip = true;
        static real poisonAOE = 400;
        static real abominationAOE = 300;
        static real wraithAOE = 250;

        static method getSummonPoint() -> Point {
            if (thistype.flip) {
                thistype.flip = !thistype.flip;
                return Point.new(5757, 9981);
            } else {
                thistype.flip = !thistype.flip;
                return Point.new(5976, 7600);
            }
        }
        
    }

}
//! endzinc
