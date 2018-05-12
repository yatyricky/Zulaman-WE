//! zinc
library CharmOfDeathFinger requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        real amt = 1500.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower();
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_CHARM_OF_DEATH_FINGER, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);  
        AddTimedLight.atUnits("AFOD", SpellEvent.CastingUnit, SpellEvent.TargetUnit, 0.7);
        AddTimedEffect.atUnit(ART_RED_IMPACT, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_DEATH_FINGER, onCast);
    }
}
//! endzinc
