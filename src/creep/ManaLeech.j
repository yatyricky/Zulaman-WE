//! zinc
library ManaLeech requires SpellEvent, DamageSystem {
constant string  ART_CASTER  = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCasterOverhead.mdl";
constant string  ART_TARGET  = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl";
constant string  ART_TARGET1  = "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl";

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



}
//! endzinc
