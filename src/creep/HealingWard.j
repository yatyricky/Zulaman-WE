//! zinc
library HealingWard requires SpellEvent, DamageSystem {
#define DURATION 20

    struct HealingWard {
        private timer tm;
        private unit caster, ward;
        private integer c;
        
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
                while (i < MobList.n) {
                    HealTarget(this.caster, MobList.units[i], GetUnitState(MobList.units[i], UNIT_STATE_MAX_LIFE) * 0.05, SpellData[SID_HEALING_WARD].name, 0.0);
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
    
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.caster = u;
            this.ward = CreateUnit(Player(MOB_PID), UTID_NTR_HEALING_WARD, GetUnitX(this.caster) + GetRandomInt(-200, 200), GetUnitY(this.caster) + GetRandomInt(-200, 200), GetRandomInt(0, 359));
            this.c = DURATION;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }

    function onCast() {
        HealingWard.start(SpellEvent.CastingUnit);
        
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEALING_WARD, onCast);
    }
#undef DURATION
}
//! endzinc
