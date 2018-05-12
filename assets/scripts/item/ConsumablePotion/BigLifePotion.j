//! zinc
library BigLifePotion requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetRandomReal(400, 800), SpellData.inst(SID_BIG_LIFE_POTION, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BIG_LIFE_POTION, onCast);
        
    }
}
//! endzinc
