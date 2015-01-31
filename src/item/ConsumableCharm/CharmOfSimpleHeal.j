//! zinc
library CharmOfSimpleHeal requires SpellEvent, ZAMCore, DamageSystem {

    function onCast() {
        real amt = 200.0 + UnitProp[SpellEvent.CastingUnit].AttackPower() + UnitProp[SpellEvent.CastingUnit].SpellPower();
        HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID_CHARM_OF_SIMPLE_HEAL].name, -3.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARM_OF_SIMPLE_HEAL, onCast);
    }
}
//! endzinc
