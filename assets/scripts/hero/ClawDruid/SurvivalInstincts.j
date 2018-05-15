//! zinc
library SurvivalInstincts requires BuffSystem, SpellEvent, UnitProperty {

    function returnPercent(integer lvl) -> real {
        return 0.2 + 0.1 * lvl;
    }
    
    function returnDuration(integer lvl) -> real {
        return 2.0 + 3.0 * lvl;
    }
    
    function returnDmgReduc(integer lvl) -> real {
        return 0.15 * lvl - 0.1;
    }

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(0 - buf.bd.i1);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_SURVIVAL_INSTINCTS);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SURVIVAL_INSTINCTS);
        real percentage;
        integer amt;
        buf.bd.tick = -1;
        buf.bd.interval = returnDuration(lvl);
        percentage = returnPercent(lvl) + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_DR_MAXHP, SCOPE_PREFIX);
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * percentage, SpellData.inst(SID_SURVIVAL_INSTINCTS, SCOPE_PREFIX).name, -3.0, false);
        if (buf.bd.i0 == 0) {
            buf.bd.i0 = 11;
            buf.bd.i1 = Rounding(GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * percentage);
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(buf.bd.i1);
        } else {
            amt = Rounding((GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) - buf.bd.i1) * percentage);
            if (amt > buf.bd.i1) {
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModLife(amt - buf.bd.i1);
                buf.bd.i1 = amt;
            }
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
        AddTimedEffect.atUnit(ART_ROAR_TARGET, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        BuffType.register(BID_SURVIVAL_INSTINCTS, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_SURVIVAL_INSTINCTS, onCast);
    }

}
//! endzinc
