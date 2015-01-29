//! zinc
library UnitAbilityCD requires TimerUtils, Integer, ZAMCore {
//==============================================================================
//
//   Simulation of Abilities Cooling Down - Beta 1.1
//      - N/A.
//                                        - by [Warft] - Nef.
//
//==============================================================================
//
//   Function List:
//
//   ---------------------------Beta 1.1------------------------------------
//
//   N/A
//
//   ---------------------------Beta 1.0------------------------------------
//
//   N/A
//
//   ---------------------------Alpha 1.1------------------------------------
//
//   1. nothing SetAbilityCD(integer aid, real tm)
//       The ability aid will be cooling down no matter who is casting it
//
//   ---------------------------Alpha 1.0------------------------------------
//
//   1. nothing SetUnitAbilityCD(unit u, integer aid, real tm)
//       Let unit u's ability - aid to be engaged coolinng down period for tm s.
//
//   2. boolean IsUnitAbilityCD(unit u, integer aid)
//       Returns true - Unit u's ability aid is still cooling down.
//       Returns false - aid is available now.
//
//==============================================================================
//
//   Example:
//
//   N/A
//          
//
//==============================================================================
//
//   Change Log:
//
//   ---------------------------Beta 1.1------------------------------------
//      N/A
//                                                  2013.02.10
//   ---------------------------Beta 1.0------------------------------------
//      N/A
//                                                  2013.02.09
//
//   ---------------------------Alpha 1.1------------------------------------
//      - Add the function - SetAbilityCD, so users no longer need to set CD
//        period each time.
//      - When first time calling IsUnitAbilityCD, it always returns false.
//                                                  - Oct., 15th, 2010
//
//   ---------------------------Alpha 1.0------------------------------------
//      - Library initially finished.
//                                                  - Oct., 12th, 2010
//
//==============================================================================
    public struct UnitAbilityCD {
        static hashtable ht;
        private unit u;
        private integer abil;
        private timer tm;
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            RemoveSavedInteger(thistype.ht, GetHandleId(this.u), this.abil);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        static method make(unit u, integer abil, real time) {
            thistype this;
            if (HaveSavedInteger(thistype.ht, GetHandleId(u), abil)) {
                this = LoadInteger(thistype.ht, GetHandleId(u), abil);
            } else {
                this = thistype.allocate();
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                SaveInteger(thistype.ht, GetHandleId(u), abil, this);
                this.u = u;
                this.abil = abil;
            } 
            TimerStart(this.tm, time, false, function thistype.run);
        }
        
        static method start(unit u, integer abil) {
            //BJDebugMsg("Making " + ID2S(abil) + " cd, for " + R2S(SpellData[abil].cd) + " secs");
            thistype.make(u, abil, SpellData[abil].CD(GetUnitAbilityLevel(u, abil)));
        }
        
        static method isCooling(unit u, integer abil) -> boolean {
            return HaveSavedInteger(thistype.ht, GetHandleId(u), abil);
        }
        
        private static method onInit() {
            thistype.ht = InitHashtable();
        }
    }    
    
    public function CoolDown(unit u, integer aid) {
        integer lvl;
        if (GetUnitAbilityLevel(u, aid) > 0) {
            lvl = GetUnitAbilityLevel(u, aid);
            UnitRemoveAbility(u, aid);
            UnitAddAbility(u, aid);
            SetUnitAbilityLevel(u, aid, lvl);
            
            UnitAbilityCD.make(u, aid, 0.0);
        }
    }
}
//! endzinc
