//! zinc
library Enigma requires ItemAttributes, DamageSystem {
    
    function onCast() {
        SetUnitX(SpellEvent.CastingUnit, GetUnitX(SpellEvent.TargetUnit));
        SetUnitY(SpellEvent.CastingUnit, GetUnitY(SpellEvent.TargetUnit));
        AddTimedEffect.atUnit(ART_ILLUSION_TARGET, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ENIGMA, onCast);
    }

}
//! endzinc
