//! zinc
library SoulLink requires BuffSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
        if (buf.bd.i0 != 0) {
            AddTimedLight(buf.bd.i0).destroy();
        }
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.TargetUnit, SpellEvent.CastingUnit, BID_SOUL_LINK);
        buf.bd.tick = -1;
        buf.bd.interval = 20;
        onRemove(buf);
        buf.bd.r0 = 5.0;
        buf.bd.i0 = AddTimedLight.atUnits("SPLK", SpellEvent.TargetUnit, SpellEvent.CastingUnit, 20.0);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_PAIN, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_SOUL_LINK, onCast);
    }

}
//! endzinc
