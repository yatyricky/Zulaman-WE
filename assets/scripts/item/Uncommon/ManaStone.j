//! zinc
library ManaStone requires ItemAttributes {
    
    function onCast() {
        real amt = ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_USE_MREGEN, SCOPE_PREFIX);
        ModUnitMana(SpellEvent.CastingUnit, amt);
        AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_STONE, onCast);
    }
}
//! endzinc
