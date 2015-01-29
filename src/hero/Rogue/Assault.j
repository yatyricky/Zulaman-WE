//! zinc
library Assault requires DamageSystem, SpellEvent, RogueGlobal, StunUtils {
#define ART "Abilities\\Weapons\\BallistaMissile\\BallistaMissileTarget.mdl"
    function onCast() {
        integer cp = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDASSAULT);
        if (ComboPoints[SpellEvent.CastingUnit].isTarget(SpellEvent.TargetUnit) && ComboPoints[SpellEvent.CastingUnit].n > 0) {
            cp += ComboPoints[SpellEvent.CastingUnit].get();
        }
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 20.0, SpellData[SIDASSAULT].name, true, false, true, WEAPON_TYPE_METAL_HEAVY_CHOP);
        if (DamageResult.isHit && !DamageResult.isBlocked) {
            StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, cp);
            DestroyEffect(AddSpecialEffectTarget(ART, DamageResult.target, "origin"));
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDASSAULT, onCast);
    }
#undef ART
}
//! endzinc
