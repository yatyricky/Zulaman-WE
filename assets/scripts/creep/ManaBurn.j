//! zinc
library ManaBurn requires DamageSystem {

    function onCast() {
        real amt = GetUnitState(SpellEvent.TargetUnit, UNIT_STATE_MAX_MANA) * 0.2;
        ModUnitMana(SpellEvent.TargetUnit, 0.0 - amt);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_MANA_BURN, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);

        AddTimedLight.atUnits("MBUR", SpellEvent.CastingUnit, SpellEvent.TargetUnit, 0.2);
        AddTimedEffect.atUnit(ART_ARCANE_TOWER_ATTACK, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_BURN, onCast);
    }
}
//! endzinc
