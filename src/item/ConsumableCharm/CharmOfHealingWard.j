//! zinc
library CharmOfHealingWard requires SpellEvent, DamageSystem {
#define DURATION 10

    struct HealingWard {
        private timer tm;
        private unit caster, ward;
        private integer c;
        private real amount;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.caster = null;
            this.ward = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            if (!IsUnitDead(this.ward)) {
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(this.ward, PlayerUnits.units[i]) < 600.0 + 197.0) {
                        HealTarget(this.caster, PlayerUnits.units[i], this.amount, SpellData[SID_CHARM_OF_HEALING_WARD].name, -3.0);
                    }
                    i += 1;
                }
            } else {
                this.destroy();
            }
            this.c -= 1;
            if (this.c < 1) {
                KillUnit(this.ward);
            }
        }
    
        static method start(unit u, real x, real y) {
            thistype this = thistype.allocate();
            this.caster = u;
            this.ward = CreateUnit(GetOwningPlayer(u), UTID_NTR_HEALING_WARD, x, y, GetRandomInt(0, 359));
            this.c = DURATION;
            this.amount = 100.0 + (UnitProp[u].AttackPower() + UnitProp[u].SpellPower()) * 0.33;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }

    function onCast() {
        HealingWard.start(SpellEvent.CastingUnit, SpellEvent.TargetX, SpellEvent.TargetY);        
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_HEALING_WARD, onCast);
    }
#undef DURATION
}
//! endzinc
