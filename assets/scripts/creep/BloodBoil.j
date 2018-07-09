//! zinc
library BloodBoil requires BuffSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).lifeRegen -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ll += buf.bd.r1;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).lifeRegen += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ll -= buf.bd.r1;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_BLOOD_BOIL);
        buf.bd.tick = -1;
        buf.bd.interval = 10;
        onRemove(buf);
        buf.bd.r0 = 800;
        buf.bd.r1 = 10;
        buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.75);
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");}
        if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BLOOD_BOIL, onCast);
        BuffType.register(BID_BLOOD_BOIL, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
