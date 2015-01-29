//! zinc
library NaturalReflex requires BuffSystem, SpellEvent, UnitProperty {
#define BUFF_ID 'A02M'
#define ART "Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdl"

    function returnHealPercent(integer lvl) -> real {
        return 0.02 * lvl;
    }
    
    function returnDodge(integer lvl) -> real {
        return 0.06 + 0.06 * lvl;
    }

    // i0 = current increment; i1 = final decrement
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].dodge += buf.bd.r0;
        SetUnitVertexColor(buf.bd.target, 255, 255, 255, 100);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].dodge -= buf.bd.r0;
        SetUnitVertexColor(buf.bd.target, 255, 255, 255, 255);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp[SpellEvent.CastingUnit].dodge -= buf.bd.r0;
        SetUnitVertexColor(SpellEvent.CastingUnit, 255, 255, 255, 255);
        buf.bd.r0 = returnDodge(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_NATURAL_REFLEX));
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 1.0);
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
                HealTarget(DamageResult.target, DamageResult.target, amt, SpellData[SID_NATURAL_REFLEX].name, -3.0);
                AddTimedEffect.atUnit(ART_HEAL, DamageResult.target, "origin", 0.2);
                if (GetUnitAbilityLevel(DamageResult.target, BUFF_ID) <= 0) {
                    ModUnitMana(DamageResult.target, 0.0 - GetUnitState(DamageResult.target, UNIT_STATE_MAX_MANA) * cost);
                }
            }
        }
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_NATURAL_REFLEX, onCast);
        RegisterDamagedEvent(clawDruidHitted);
    }
#undef ART
#undef BUFF_ID 
}
//! endzinc
