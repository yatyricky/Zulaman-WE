//! zinc
library ProtectionWard requires SpellEvent, BuffSystem {
#define DURATION 30
#define BUFF_ID 'A09B'

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += 0.95;
    }

    struct ProtectionWard {
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
            Buff buf;
            if (!IsUnitDead(this.ward)) {
                while (i < MobList.n) {
                    if (CanUnitAttack(MobList.units[i])) {
                        buf = Buff.cast(this.caster, MobList.units[i], BUFF_ID);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            UnitProp[buf.bd.target].damageTaken -= 0.95;
                            buf.bd.i0 = 6;
                        }
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run(); 
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
    
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.caster = u;
            this.ward = CreateUnit(Player(MOB_PID), UTID_NTR_PROTECTION_WARD, GetUnitX(this.caster) + GetRandomInt(-200, 200), GetUnitY(this.caster) + GetRandomInt(-200, 200), GetRandomInt(0, 359));
            this.c = DURATION;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }

    function onCast() {
        ProtectionWard.start(SpellEvent.CastingUnit);        
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_PROTECTION_WARD, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
    }
#undef BUFF_ID
#undef DURATION
}
//! endzinc
