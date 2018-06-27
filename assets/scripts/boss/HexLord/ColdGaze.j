//! zinc
library ColdGaze requires DamageSystem {

    function castAny() {
        Buff buf;
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, BID_ColdGaze) == 0) return;
        buf = BuffSlot[SpellEvent.CastingUnit].getBuffByBid(BID_ColdGaze);
        DamageTarget(buf.bd.caster, buf.bd.target, 200, SpellData.inst(SID_COLD_GAZE, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_SOUL_ORBIT, buf.bd.target, "origin", 0.05);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_ColdGaze);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_SOUL_ORBIT, buf, "overhead");}
        buf.bd.boe = Buff.noEffect;
        buf.bd.bor = Buff.noEffect;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_COLD_GAZE, onCast);
        RegisterSpellEffectResponse(0, castAny);
        BuffType.register(BID_ColdGaze, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
