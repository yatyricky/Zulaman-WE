//! zinc
library ViciousStrike requires StunUtils {

    function onEffect(Buff buf) {
        StunUnit(buf.bd.caster, buf.bd.target, 1.0);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_VICIOUS_STRIKE);
        buf.bd.interval = 2.0;
        buf.bd.tick = 5;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_VICIOUS_STRIKE, onCast);
        BuffType.register(BID_VICIOUS_STRIKE, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
