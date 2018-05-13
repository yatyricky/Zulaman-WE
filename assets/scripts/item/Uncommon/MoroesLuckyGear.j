//! zinc
library MoroesLuckyGear requires ItemAttributes {

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_MOROES_LUCKY_GEAR);
        buf.bd.tick = -1;
        buf.bd.interval = ItemExAttributes.getUnitAttributeValue(SpellEvent.CastingUnit, IATTR_USE_DODGE, 0.16, SCOPE_PREFIX);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MOROES_LUCKY_GEAR, onCast);
        BuffType.register(BID_MOROES_LUCKY_GEAR, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
