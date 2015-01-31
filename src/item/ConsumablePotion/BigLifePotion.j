//! zinc
library BigLifePotion requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetRandomReal(400, 800), SpellData[SID_BIG_LIFE_POTION].name, 0.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BIG_LIFE_POTION, onCast);
        
    }
}
//! endzinc
