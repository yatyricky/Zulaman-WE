//! zinc
library FelGuardsGlobals {

    public struct FelGuardsGlobals {
        static unit bossGuard = null;
        static unit bossDefender = null;
        static integer stage = 0;
    
        static method reset() {
            thistype.stage = 0;
        }

    }

}
//! endzinc
