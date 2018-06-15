//! zinc
library Rejuvenation requires BuffSystem, SpellEvent, UnitProperty {

    function returnHeal(integer lvl) -> real {
        return 50.0 + 100.0 * lvl;
    }
    
    function returnCriticalValue(integer lvl) -> integer {
        return 20 * lvl;
    }

    function onEffect(Buff buf) {
        real percent = GetUnitStatePercent(buf.bd.target, UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE);
        if (percent < buf.bd.i0) {
            percent = buf.bd.i0;
        }
        percent = (100.0 - percent) / (100 - buf.bd.i0) * 0.5;
        HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(SID_REJUVENATION, SCOPE_PREFIX).name, percent, false);
        AddTimedEffect.atUnit(ART_RejuvenationTarget, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {
    }
    
    function onEffect1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_REJUVENATION);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_REJUVENATION);
        buf.bd.r0 = returnHeal(lvl) + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower() * 1.2;
        buf.bd.i0 = returnCriticalValue(lvl);
        buf.bd.interval = 3.0 / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste());
        buf.bd.tick = Rounding(12.0 / buf.bd.interval);
        buf.bd.i1 = buf.bd.tick;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_RejuvenationTarget, SpellEvent.TargetUnit, "origin", 1.0);
    }

    function onInit() {
        BuffType.register(BID_REJUVENATION, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_REJUVENATION, onCast);
    }

}
//! endzinc
