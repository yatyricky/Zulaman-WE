//! zinc
library CharmOfSimpleHeal requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        real amt = 200.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower();
        HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_CHARM_OF_SIMPLE_HEAL, SCOPE_PREFIX).name, -3.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_SIMPLE_HEAL, onCast);
    }
}
//! endzinc
