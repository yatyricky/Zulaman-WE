//! zinc
library FlameShock requires DamageSystem {
/*
deals 400 magical damage to target
then deals 400 magical damage to target every 2 seconds.
Magical negative effect
*/
#define ART "Doodads\\Cinematic\\TownBurningFireEmitter\\TownBurningFireEmitter.mdl"
#define IMPACT "Doodads\\Cinematic\\FireTrapUp\\FireTrapUp.mdl"

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_FLAME_SHOCK].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.3);
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
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_FLAME_SHOCK);
        buf.bd.interval = 2;
        buf.bd.tick = 5;
        buf.bd.r0 = 400.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SID_FLAME_SHOCK].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(IMPACT, buf.bd.target, "origin", 1.0);
    }

    function onInit() {
        BuffType.register(BID_FLAME_SHOCK, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_FLAME_SHOCK, onCast);
    }
#undef ART
#undef IMPACT
}
//! endzinc
