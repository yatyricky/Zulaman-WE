//! zinc
library CharmOfSiphonLife requires BuffSystem, SpellEvent, DamageSystem {
#define BUFF_ID 'A0AE'
#define ART_TARGET "Abilities\\Spells\\Other\\Drain\\DrainTarget.mdl"
#define ART_CASTER "Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl"

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_CHARM_OF_SIPHON_LIFE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        HealTarget(buf.bd.caster, buf.bd.caster, DamageResult.amount, SpellData[SID_CHARM_OF_SIPHON_LIFE].name, -3.0);
        AddTimedEffect.atUnit(ART_TARGET, buf.bd.target, "overhead", 0.2);
        AddTimedEffect.atUnit(ART_CASTER, buf.bd.caster, "overhead", 0.2);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.interval = 3.0;
        buf.bd.tick = 7;
        buf.bd.r0 = 200.0 + (UnitProp[SpellEvent.CastingUnit].AttackPower() + UnitProp[SpellEvent.CastingUnit].SpellPower()) * 0.5;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "overhead", 0.2);
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_CHARM_OF_SIPHON_LIFE, onCast);
    }
#undef ART_CASTER
#undef ART_TARGET
#undef BUFF_ID 
}
//! endzinc
