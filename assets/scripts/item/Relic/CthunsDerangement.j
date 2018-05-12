//! zinc
library CthunsDerangement requires ItemAttributes, DamageSystem {
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_CTHUNS_ACTIVE_IAS);
        real exdmg = 0;
        integer ii = 0;
        item ti;
        while (ii < 6) {
            ti = UnitItemInSlot(SpellEvent.CastingUnit, ii);
            if (ti != null) {
                exdmg += ItemExAttributes.getAttributeValue(ti, IATTR_USE_CTHUN, SCOPE_PREFIX + "onCast") / (ItemExAttributes.getAttributeValue(ti, IATTR_LP, "onCast") + 1);
            }
            ii += 1;
        }
        ti = null;
        
        buf.bd.tick = -1;
        buf.bd.interval = 10;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
        buf.bd.r0 = exdmg;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 100;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_UNHOLY_FRENZY_TARGET, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CTHUNS_DERANGEMENT, onCast);
        BuffType.register(BID_CTHUNS_ACTIVE_IAS, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
