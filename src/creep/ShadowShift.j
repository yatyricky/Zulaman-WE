//! zinc
library ShadowShift {
/*
deals 20% damage of target's max life to target.
heal the caster equals 5 times of damage dealt
*/

	function onCast() {
        real amt = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_lIFE) * 0.2;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);   
    	HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt * 5.0, SpellData[SID].name, 0.0);
	}

	function onInit() {
		RegisterSpellEffectResponse(SID, onCast);
	}
}
//! endzinc
 