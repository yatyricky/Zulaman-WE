//! zinc
library ManaLeech requires SpellEvent, DamageSystem {
#define ART_CASTER "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCasterOverhead.mdl"
#define ART_TARGET "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
#define ART_TARGET1 "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl"

	function returnFactor() -> real {
		return 25.0;
	}
    
    function onCast() {
        real t = GetUnitManaPercent(SpellEvent.TargetUnit);
		if (t > returnFactor()) {
			t = returnFactor();
		}
		t = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_MANA) * t * 0.01;
		ModUnitMana(SpellEvent.TargetUnit, 0.0 - t);
		ModUnitMana(SpellEvent.CastingUnit, t);
		AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "overhead", 1.0);
		AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 1.0);
		AddTimedEffect.atUnit(ART_TARGET1, SpellEvent.TargetUnit, "overhead", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_LEECH, onCast);
    }
#undef ART_TARGET1
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
