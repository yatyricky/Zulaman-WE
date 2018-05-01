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

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModInt(7 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
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
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_ICON_OF_THE_UNGLAZED_CRESCENT, action);
        RegisterSpellEffectResponse(SID_ICON_OF_THE_UNGLAZED_CRESCENT, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
