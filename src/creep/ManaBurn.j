//! zinc
library ManaBurn {
/*
burn target 20% mana, and deals same amount of damage
*/
    function onCast() {
		real amt = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_MANA) * 0.2;
		ModUnitMana(SpellEvent.TargetUnit, 0.0 - amt);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);

        AddTimedLight.atUnits("MNBN", SpellEvent.CastingUnit, SpellEvent.TargetUnit, 0.2);
        AddTimedEffect.atUnit(IMPACT, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
    }
}
//! endzinc
 