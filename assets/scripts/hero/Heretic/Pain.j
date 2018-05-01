//! zinc
library Pain requires BuffSystem, SpellEvent, UnitProperty {

    function returnDamage(integer lvl, real sp) -> real {
        return 120 + sp * 1.2;
    }
    
    function returnInterval(integer lvl) -> real {
        return 3.5 - 0.5 * lvl;
    }
    
    function returnSpellTaken(integer lvl) -> real {
        return 0.03 + 0.02 * lvl;
    }

    function onEffect1(Buff buf) { 
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
    }

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_PAIN].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_PAIN);
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_PAIN);
        buf.bd.interval = returnInterval(lvl) / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste());
        buf.bd.tick = Rounding(12.0 / buf.bd.interval);
        buf.bd.r0 = returnDamage(lvl, UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_PAIN_WEAKNESS);
        buf.bd.tick = -1;
        buf.bd.interval = 12;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
        buf.bd.r0 = returnSpellTaken(lvl);
        buf.bd.boe = onEffect1;
        buf.bd.bor = onRemove1;
        buf.run();
        AddTimedEffect.atUnit(ART_PLAGUE, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(BID_PAIN, BUFF_MAGE, BUFF_NEG);
        BuffType.register(BID_PAIN_WEAKNESS, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_PAIN, onCast);
    }
}
//! endzinc
