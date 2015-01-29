//! zinc
library Shield requires BuffSystem, UnitProperty, SpellEvent, UnitAbilityCD, Heal, Benediction {
#define BUFF_ID 'A01I'
#define BUFF_ID1 'A01J'

    function returnAbsorb(integer lvl, real sp) -> real {
        return 750.0 * lvl + sp * 4.0;
    }
    
    struct delayedDosth1 {
        private timer tm;
        private unit u;
        private real amt;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            ModUnitMana(this.u, this.amt);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
    
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.u = u;
            this.tm = NewTimer();
            this.amt = 75 + 25 * GetUnitAbilityLevel(this.u, SIDSHIELD);
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }

    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}
    function onEffect1(Buff buf) {}
    function onRemove1(Buff buf) {}

    function onCast() {
        Buff buf;
        buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BUFF_ID1);
        if (buf == 0) {
            // shield
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 20.0;
            buf.bd.isShield = true;
            buf.bd.r0 = returnAbsorb(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSHIELD), UnitProp[SpellEvent.CastingUnit].SpellPower());
            if (buf.bd.e0 == 0) {
                buf.bd.e0 = BuffEffect.create(ART_SHIELD, buf, "overhead");
            }
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            
            if (!HasBenediction(SpellEvent.CastingUnit)) {
                // soul weaken
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID1);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
            }
            
            if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSHIELD) > 1) {
                if (GetRandomInt(0, 99) < 35 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDHEAL) > 0) {
                    PriestCastHeal(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 2 * GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSHIELD) - 1);
                }
            }
        } else {
            delayedDosth1.start(SpellEvent.CastingUnit);
            CoolDown(SpellEvent.CastingUnit, SIDSHIELD);
        }
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SIDSHIELD, onCast);
    }
#undef BUFF_ID1
#undef BUFF_ID
}
//! endzinc
