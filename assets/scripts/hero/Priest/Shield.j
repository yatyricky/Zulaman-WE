//! zinc
library Shield requires BuffSystem, UnitProperty, SpellEvent, UnitAbilityCD, Heal {

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
            this.amt = 75 + 25 * GetUnitAbilityLevel(this.u, SID_SHIELD);
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
        buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BID_SHIELD_SOUL_WEAK);
        if (buf == 0) {
            // shield
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_SHIELD);
            buf.bd.tick = -1;
            buf.bd.interval = 20.0;
            buf.bd.isShield = true;
            buf.bd.r0 = returnAbsorb(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SHIELD), UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower());
            if (buf.bd.e0 == 0) {
                buf.bd.e0 = BuffEffect.create(ART_SHIELD, buf, "overhead");
            }
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            
            if (UnitHasItemOfTypeBJ(SpellEvent.CastingUnit, ITID_BENEDICTION) == false) {
                // soul weaken
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_SHIELD_SOUL_WEAK);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
            }
        } else {
            delayedDosth1.start(SpellEvent.CastingUnit);
            CoolDown(SpellEvent.CastingUnit, SID_SHIELD);
        }
    }

    function onInit() {
        BuffType.register(BID_SHIELD, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_SHIELD_SOUL_WEAK, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_SHIELD, onCast);
    }

}
//! endzinc
