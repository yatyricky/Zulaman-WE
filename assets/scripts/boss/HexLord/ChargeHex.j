//! zinc
library ChargeHex requires SpellEvent, BuffSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_ELEMENTAL_ENPOWER);
        buf.bd.tick = -1;
        buf.bd.interval = 7;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
        buf.bd.r0 = 0.5;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_PurgeBuffTarget, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARGE_HEX, onCast);
    }

}
//! endzinc
