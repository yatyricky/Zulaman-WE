//! zinc
library FlameThrow requires SpellEvent, DamageSystem, GroupUtils {
#define MISSILE "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
#define IMPACT "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"

    struct FlameThrow {
        private timer tm;
        private unit a, mis;
        private integer tick;
        private real x, y;
        private group damaged;
        private effect eff;
        
        private method destroy() {
            DestroyEffect(this.eff);
            KillUnit(this.mis);
            ReleaseGroup(this.damaged);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.damaged = null;
            this.a = null;
            this.mis = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real nextx;
            real nexty;
            integer i = 0;
            nextx = GetUnitX(this.mis) + this.x;
            nexty = GetUnitY(this.mis) + this.y;
            if (this.tick < 75) {
                SetUnitX(this.mis, nextx);
                SetUnitY(this.mis, nexty);
                this.tick += 1;
                
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.mis) < 150 && !IsUnitDead(PlayerUnits.units[i]) && !IsUnitInGroup(PlayerUnits.units[i], this.damaged)) {
                        DamageTarget(this.a, PlayerUnits.units[i], 250.0 + GetRandomReal(0.0, 100.0), SpellData[SIDFLAMETHROW].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                        AddTimedEffect.atUnit(IMPACT, PlayerUnits.units[i], "origin", 0.0);
                        GroupAddUnit(this.damaged, PlayerUnits.units[i]);
                    }
                    i += 1;
                }
            } else {
                this.destroy();
            }
        }
        
        static method start(unit a, unit b) {
            thistype this = thistype.allocate();
            real angle = GetAngle(GetUnitX(a), GetUnitY(a), GetUnitX(b), GetUnitY(b));
            this.a = a;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.x = Cos(angle) * 20.0;
            this.y = Sin(angle) * 20.0;
            this.tick = 0;
            this.damaged = NewGroup();
            this.mis = CreateUnit(Player(0), DUMMY_ID, GetUnitX(a), GetUnitY(a), Rad2Deg(angle));
            SetUnitFlyable(this.mis);
            SetUnitFlyHeight(this.mis, 50.0, 0.0);
            //SetUnitScale(this.mis, 2.0, 2.0, 2.0);
            this.eff = AddSpecialEffectTarget(MISSILE, this.mis, "origin");
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }

    function onCast() {
        FlameThrow.start(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDFLAMETHROW, onCast);
    }
#undef IMPACT
#undef MISSILE
}
//! endzinc
