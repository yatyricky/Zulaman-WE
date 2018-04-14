//! zinc
library NetherSlow requires BuffSystem {

    function onEffect1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_NETHER_SLOW);
        buf.bd.tick = -1;
        buf.bd.interval = 3.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
        buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.75);
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_SLOW, buf, "origin");
        }
        buf.bd.boe = onEffect1;
        buf.bd.bor = onRemove1;
        buf.run();
    }
    
    function onInit() {
        RegisterSpellEffectResponse(SID_NETHER_SLOW, onCast);
        BuffType.register(BID_NETHER_SLOW, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
 