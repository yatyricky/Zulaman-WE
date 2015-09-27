//! zinc
library NaturalReflexHex requires BuffSystem, SpellEvent, UnitProperty {
// #define ART "Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdl"

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
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_NATURAL_REFLEX_HEX);
        buf.bd.tick = -1;
        buf.bd.interval = 6.0;
        UnitProp[SpellEvent.CastingUnit].dodge -= buf.bd.r0;
        SetUnitVertexColor(SpellEvent.CastingUnit, 255, 255, 255, 255);
        buf.bd.r0 = 1.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        // AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 1.0);
    }
    
    function hexLordHitted() {
        integer ilvl;
        if (DamageResult.isDodged) {
            ilvl = GetUnitAbilityLevel(DamageResult.target, BID_NATURAL_REFLEX_HEX);
            if (ilvl > 0) {
                HealTarget(DamageResult.target, DamageResult.target, GetUnitState(DamageResult.target, UNIT_STATE_MAX_LIFE) * 0.1, SpellData[SID_NATURAL_REFLEX_HEX].name, -3.0);
                AddTimedEffect.atUnit(ART_HEAL, DamageResult.target, "origin", 0.2);
            }
        }
    }

    function onInit() {
        BuffType.register(BID_NATURAL_REFLEX_HEX, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_NATURAL_REFLEX_HEX, onCast);
        RegisterDamagedEvent(hexLordHitted);
    }
// #undef ART
}
//! endzinc
