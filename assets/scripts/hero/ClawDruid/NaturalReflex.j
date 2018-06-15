//! zinc
library NaturalReflex requires BuffSystem, SpellEvent, UnitProperty {

    function returnHealPercent(integer lvl) -> real {
        return 0.02 * lvl;
    }
    
    function returnDodge(integer lvl) -> real {
        return 0.06 + 0.06 * lvl;
    }

    // i0 = current increment; i1 = final decrement
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge += buf.bd.r0;
        SetUnitVertexColor(buf.bd.target, 255, 255, 255, 100);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
        SetUnitVertexColor(buf.bd.target, 255, 255, 255, 255);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_NATURAL_REFLEX);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).dodge -= buf.bd.r0;
        SetUnitVertexColor(SpellEvent.CastingUnit, 255, 255, 255, 255);
        buf.bd.r0 = returnDodge(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_NATURAL_REFLEX));
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        AddTimedEffect.atUnit(ART_InvisibilityTarget, SpellEvent.CastingUnit, "origin", 1.0);
    }
    
    function clawDruidHitted() {
        integer ilvl;
        real cost, amt;
        if (DamageResult.isDodged) {
            ilvl = GetUnitAbilityLevel(DamageResult.target, SID_NATURAL_REFLEX);
            if (ilvl > 0) {
                cost = GetUnitState(DamageResult.target, UNIT_STATE_MANA) / GetUnitState(DamageResult.target, UNIT_STATE_MAX_MANA);
                if (cost > 0.1) {
                    cost = 0.1;
                }
                amt = (returnHealPercent(ilvl) * GetUnitState(DamageResult.target, UNIT_STATE_MAX_LIFE)) * (cost / 0.1);
                HealTarget(DamageResult.target, DamageResult.target, amt, SpellData.inst(SID_NATURAL_REFLEX, SCOPE_PREFIX).name, -3.0, false);
                AddTimedEffect.atUnit(ART_HEAL, DamageResult.target, "origin", 0.2);
                if (GetUnitAbilityLevel(DamageResult.target, BID_NATURAL_REFLEX) <= 0) {
                    ModUnitMana(DamageResult.target, 0.0 - GetUnitState(DamageResult.target, UNIT_STATE_MAX_MANA) * cost);
                }
            }
        }
    }

    function onInit() {
        BuffType.register(BID_NATURAL_REFLEX, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_NATURAL_REFLEX, onCast);
        RegisterDamagedEvent(clawDruidHitted);
    }

}
//! endzinc
