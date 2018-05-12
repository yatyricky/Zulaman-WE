//! zinc
library ManaStone requires ItemAttributes {
    
    function onCast() {
        ModUnitMana(SpellEvent.CastingUnit, GetRandomReal(200.0, 400.0));
        AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_STONE, onCast);
    }
}
//! endzinc
