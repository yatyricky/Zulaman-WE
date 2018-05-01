//! zinc
library FelFrenzy requires SpellEvent, BuffSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i1);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_FEL_FRENZY);
        buf.bd.tick = -1;
        buf.bd.interval = 7;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
        buf.bd.i0 = 1000;
        buf.bd.i1 = 75;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FEL_FRENZY, onCast);
        BuffType.register(BID_FEL_FRENZY, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
