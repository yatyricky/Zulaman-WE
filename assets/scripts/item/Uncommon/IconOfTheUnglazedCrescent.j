//! zinc
library IconOfTheUnglazedCrescent requires ItemAttributes {

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_ICON_OF_THE_UNGLAZED_CRESCENT);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(0 - buf.bd.i0);
        buf.bd.i0 = Rounding(ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_USE_INT, SCOPE_PREFIX));
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ICON_OF_THE_UNGLAZED_CRESCENT, onCast);
        BuffType.register(BID_ICON_OF_THE_UNGLAZED_CRESCENT, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
