//! zinc
library SunfireStorm requires SpellEvent, TimerUtils, AggroSystem {
#define ART_CASTER "Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl"
#define ART_EFFECT "Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl"

    struct SunFieldHex {
        real dmg;
        integer count;
        unit caster;
        real aoe;
        timer tm;
        real x, y;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            if (IsInCombat()) {
                while (i < PlayerUnits.n) {
                    if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < 150 && !IsUnitDead(PlayerUnits.units[i])) {
                        DamageTarget(this.caster, PlayerUnits.units[i], this.dmg, SpellData[SIDSUNFIRESTORMHEX].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    }
                    i += 1;
                }
            }
            this.count -= 1;
            if (this.count < 1) {
                this.destroy();
            }
        }
    
        static method new(unit u, real x, real y) {
            thistype this = thistype.allocate();
            this.caster = u;
            this.aoe = 150.0;
            this.count = 8;
            this.dmg = 300.0;
            this.x = x;
            this.y = y;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
            AddTimedEffect.atCoord(ART_CASTER, this.x, this.y, 0.0);
            AddTimedEffect.atCoord(ART_EFFECT, this.x, this.y, this.count);
        }
    }

    function onCast() {
        unit target = AggroList[SpellEvent.CastingUnit].getFirst();
        real x = GetUnitX(target);
        real y = GetUnitY(target);
        unit tar = PlayerUnits.getRandomInRange(SpellEvent.CastingUnit, 3600.0);
        if (tar != null) {
            x = GetUnitX(tar);
            y = GetUnitY(tar);
        }
        SunFieldHex.new(SpellEvent.CastingUnit, x, y);  
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDSUNFIRESTORMHEX, onCast);
    }
#undef ART_EFFECT
#undef ART_CASTER
}
//! endzinc
