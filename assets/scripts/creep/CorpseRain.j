//! zinc
library CorpseRain requires DamageSystem {
    private struct CorpseFall {
        unit mis;
        timer tm;
        effect eff;

        method destroy() {
            ReleaseTimer(this.tm);
            AddTimedEffect.atCoord(ART_MEATWAGON_MISSILE, GetUnitX(this.mis), GetUnitY(this.mis), 0.01);
            KillUnit(this.mis);
            DestroyEffect(this.eff);
            this.tm = null;
            this.mis = null;
            this.eff = null;
            this.deallocate();
        }
        
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real h = GetUnitFlyHeight(this.mis) - 36.0;
            if (h < 0.0) {
                h = 0.0;
            }
            SetUnitFlyHeight(this.mis, h, 0);
            if (h < 36.0) {
                this.destroy();
            }
        }

        static method start(real x, real y, real r) {
            thistype this = thistype.allocate();
            real angle, distance;

            angle = GetRandomReal(0.0, 6.283);
            distance = SquareRoot(GetRandomReal(1.0, r * r));

            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.mis = CreateUnit(Player(MOB_PID), DUMMY_ID, Cos(angle) * distance + x, Sin(angle) * distance + y, GetRandomReal(1, 360));
            SetUnitFlyable(this.mis);
            SetUnitFlyHeight(this.mis, 900.0, 0);
            this.eff = AddSpecialEffectTarget(ART_MEATWAGON_MISSILE, this.mis, "origin");
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    struct CorpseRain {
        timer tm;
        real x, y;
        integer count;
        unit caster;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.tm = null;
            this.deallocate();
        }
    
        static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i;
            
            if (ModuloInteger(this.count, 25) == 0) {
                // Damage
                for (0 <= i < PlayerUnits.n) {
                    if (GetDistance.unitCoord(PlayerUnits.units[i], this.x, this.y) < 350.0) {
                        DamageTarget(this.caster, PlayerUnits.units[i], 300.0, SpellData[SID_CORPSE_RAIN].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                    }
                }
                // Heal
                for (0 <= i < MobList.n) {
                    if (GetDistance.unitCoord(MobList.units[i], this.x, this.y) < 350.0) {
                        HealTarget(this.caster, MobList.units[i], 2000, SpellData[SID_CORPSE_RAIN].name, 0.0);
                    }
                }
            }
            
            if (GetRandomReal(0, 1.0) < 0.3) {
                CorpseFall.start(this.x, this.y, 350.0);
            }
            
            this.count -= 1;
            if (this.count <= 0) {
                this.destroy();
            }
        }
    
        static method start(unit caster, real x, real y) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            
            this.caster = caster;
            this.x = x;
            this.y = y;
            this.count = 149;
            
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        CorpseRain.start(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CORPSE_RAIN, onCast);
    }
}
//! endzinc
