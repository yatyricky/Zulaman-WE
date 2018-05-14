//! zinc
library HexShrunkenHead requires ItemAttributes {

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower -= buf.bd.r0;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_HEX_SHRUNKEN_HEAD);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellPower -= buf.bd.r0;
        buf.bd.r0 = ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_USE_SP, SCOPE_PREFIX);
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
        
        AddTimedEffect.atUnit(ART_INTELLIGENCE, SpellEvent.CastingUnit, "origin", 0.5);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEX_SHRUNKEN_HEAD, onCast);
        BuffType.register(BID_HEX_SHRUNKEN_HEAD, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
