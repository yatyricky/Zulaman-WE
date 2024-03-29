//! zinc
library Death requires SpellEvent, UnitProperty {
constant string  ART_CASTER  = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl";
//define ART_TARGET "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
constant string  ART_TARGET  = "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl";

    function returnSacrifice(integer lvl, real life) -> real {
        return life * 0.2;
    }
    
    function returnDamage(integer lvl, real life, real sp) -> real {
        return life * lvl + sp;
    }

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DEATH);
        real dmg = returnSacrifice(lvl, GetWidgetLife(SpellEvent.CastingUnit));
        DamageTarget(SpellEvent.TargetUnit, SpellEvent.CastingUnit, dmg, SpellData.inst(SID_DEATH, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
        dmg = returnDamage(lvl, dmg, UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower());
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_DEATH, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.2);
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DEATH, onCast);
    }


}
//! endzinc
