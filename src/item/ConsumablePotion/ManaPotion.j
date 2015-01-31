//! zinc
library ManaPotion requires SpellEvent, ZAMCore {

    function onCast() {
        ModUnitMana(SpellEvent.CastingUnit, GetRandomReal(100, 300));
        AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_POTION, onCast);
        
    }
}
//! endzinc
