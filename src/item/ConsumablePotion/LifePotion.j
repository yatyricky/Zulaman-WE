//! zinc
library LifePotion requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetRandomReal(200, 400), SpellData[SID_LIFE_POTION].name, 0.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_LIFE_POTION, onCast);
        
    }
}
//! endzinc
