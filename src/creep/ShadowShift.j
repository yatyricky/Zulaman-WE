//! zinc
library ShadowShift requires DamageSystem {

	function onCast() {
        real amt = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_LIFE) * 0.2;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID_SHADOW_SHIFT].name, false, false, false, WEAPON_TYPE_WHOKNOWS);   
    	HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * 0.2, SpellData[SID_SHADOW_SHIFT].name, 0.0);
        AddTimedEffect.atUnit(ART_ILLUSION_TARGET, SpellEvent.TargetUnit, "origin", 0.0);
	}

	function onInit() {
		RegisterSpellEffectResponse(SID_SHADOW_SHIFT, onCast);
	}
}
//! endzinc
 