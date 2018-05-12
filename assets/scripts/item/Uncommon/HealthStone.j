//! zinc
library HealthStone requires ItemAttributes {
    
    function onCast() {
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetRandomReal(300.0, 600.0), SpellData.inst(SID_HEALTH_STONE, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEALTH_STONE, onCast);
    }
}
//! endzinc
