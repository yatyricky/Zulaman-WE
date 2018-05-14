//! zinc
library GoblinRocketBootsLimitedEdition requires ItemAttributes {

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION);
        buf.bd.tick = -1;
        buf.bd.interval = ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_USE_MS, SCOPE_PREFIX);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 300;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, onCast);
        BuffType.register(BID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
