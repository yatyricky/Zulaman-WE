//! zinc
library HealthStone requires ItemAttributes {
    
    function onCast() {
        real amt = ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_USE_HREGEN, SCOPE_PREFIX);
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt, SpellData.inst(SID_HEALTH_STONE, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEALTH_STONE, onCast);
    }
}
//! endzinc
