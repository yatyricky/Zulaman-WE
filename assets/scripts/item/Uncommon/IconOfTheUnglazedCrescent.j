//! zinc
library IconOfTheUnglazedCrescent requires ItemAttributes {
constant integer BUFF_ID = 'A06F';
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModInt(0 - buf.bd.i0);
        buf.bd.i0 = 15;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ICON_OF_THE_UNGLAZED_CRESCENT, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
