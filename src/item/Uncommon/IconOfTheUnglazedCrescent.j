//! zinc
library IconOfTheUnglazedCrescent requires ItemAttributes {
#define BUFF_ID 'A06F'
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].ModInt(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].ModInt(0 - buf.bd.i0);
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModInt(7 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        UnitProp[buf.bd.target].ModInt(0 - buf.bd.i0);
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
#undef BUFF_ID
}
//! endzinc
