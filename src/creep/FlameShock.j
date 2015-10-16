//! zinc
library FlameShock {
/*
deals 400 magical damage to target
then deals 400 magical damage to target every 2 seconds.
Magical negative effect
*/
#define ART
#define IMPACT

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf;
        unit tmp;
        if (TryReflect(SpellEvent.TargetUnit)) {
            tmp = SpellEvent.TargetUnit;
            SpellEvent.TargetUnit = SpellEvent.CastingUnit;
            SpellEvent.CastingUnit = tmp;
        }
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID);
        buf.bd.interval = 2;
        buf.bd.tick = 5;
        buf.bd.r0 = 400.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(IMPACT, buf.bd.target, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID, onCast);
    }
#undef ART
#undef IMPACT
}
//! endzinc
