//! zinc
library GrimTotem requires SpellEvent, BuffSystem {

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += 0.65;
    }

    struct GrimTotem {
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
                for (0 <= i < PlayerUnits.n) {
                    if (CanUnitAttack(PlayerUnits.units[i])) {
                        buf = Buff.cast(this.caster, PlayerUnits.units[i], BID_GRIM_TOTEM);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            UnitProp[buf.bd.target].damageDealt -= 0.65;
                            buf.bd.i0 = 6;
                        }
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run(); 
                    }
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
            this.ward = CreateUnit(Player(MOB_PID), UTID_GRIM_TOTEM, GetUnitX(u) + GetRandomInt(-200, 200), GetUnitY(u) + GetRandomInt(-200, 200), GetRandomInt(0, 359));
            this.c = 30;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 1.0, true, function thistype.run);
        }
    }

    function onCast() {
        GrimTotem.start(SpellEvent.CastingUnit);        
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_GRIM_TOTEM, onCast);
        BuffType.register(BID_GRIM_TOTEM, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
