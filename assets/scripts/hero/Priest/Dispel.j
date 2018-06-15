//! zinc
library Dispel requires BuffSystem, SpellEvent, UnitProperty {

    function onEffect1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
    }

    function onCast() {
        Buff buf;
        if (IsUnitAlly(SpellEvent.TargetUnit, GetOwningPlayer(SpellEvent.CastingUnit))) {
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_NEG);
            if (buf != 0) {
                buf.destroy();
            }
            if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DISPEL) > 1) {
                buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_DISPEL);
                buf.bd.tick = -1;
                buf.bd.interval = 3.0;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
                buf.bd.r0 = 0.15 * (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DISPEL) - 1);
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
            }
        } else {
            buf = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_POS);
            if (buf != 0) {
                buf.destroy();
            }
        }
        AddTimedEffect.atUnit(ART_DISPEL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DISPEL, onCast);
        BuffType.register(BID_DISPEL, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
