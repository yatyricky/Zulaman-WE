//! zinc
library Death requires SpellEvent, UnitProperty {
#define ART_CASTER "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosDone.mdl"
//define ART_TARGET "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
#define ART_TARGET "Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl"

    function returnSacrifice(integer lvl, real life) -> real {
        return life * 0.2;
    }
    
    function returnDamage(integer lvl, real life, real sp) -> real {
        return life * lvl + sp;
    }

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDEATH);
        real dmg = returnSacrifice(lvl, GetWidgetLife(SpellEvent.CastingUnit));
        DamageTarget(SpellEvent.TargetUnit, SpellEvent.CastingUnit, dmg, SpellData[SIDDEATH].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        dmg = returnDamage(lvl, dmg, UnitProp[SpellEvent.CastingUnit].SpellPower());
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDDEATH].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.2);
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDEATH, onCast);
    }
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
