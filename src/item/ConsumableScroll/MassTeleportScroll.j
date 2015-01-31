//! zinc
library MassTeleportScroll requires SpellEvent, ZAMCore {
#define ART_READY "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTo.mdl"
#define ART_ORIGIN "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportCaster.mdl"
#define ART_TARGET "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl"
    
    struct delayedDosth1 {
        private timer tm;
        private unit u;
        private real rx, ry;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real x, y;
            real xo, yo;
            integer i = 0;
            xo = GetUnitX(this.u);
            yo = GetUnitY(this.u);
            while (i < PlayerUnits.n) {
                //BJDebugMsg(GetUnitNameEx(SpellEvent.CastingUnit) + " & " + GetUnitNameEx(PlayerUnits.units[i]) + " distance = " + R2S(GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit)));
                if (GetDistance.unitCoord2d(PlayerUnits.units[i], xo, yo) <= 600.0 && !IsUnitDead(PlayerUnits.units[i])) {
                    x = GetUnitX(PlayerUnits.units[i]);
                    y = GetUnitY(PlayerUnits.units[i]);
                    AddTimedEffect.atCoord(ART_ORIGIN, x, y, 1.0);
                    MoveUnit(PlayerUnits.units[i], this.rx + x - xo, this.ry + y - yo);
                    AddTimedEffect.atUnit(ART_TARGET, PlayerUnits.units[i], "origin", 1.0);
                }
                i += 1;
            }
            
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
    
        static method start(unit u, real x, real y) {
            thistype this = thistype.allocate();
            this.u = u;
            this.rx = x;
            this.ry = y;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }

    function onCast() {
        delayedDosth1.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);
        AddTimedEffect.atCoord(ART_READY, SpellEvent.TargetX, SpellEvent.TargetY, 2.4);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MASS_TELEPORT_SCROLL, onCast);        
    }
#undef ART_TARGET
#undef ART_ORIGIN
#undef ART_READY
}
//! endzinc
