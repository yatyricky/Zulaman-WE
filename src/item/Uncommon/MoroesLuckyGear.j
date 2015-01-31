//! zinc
library MoroesLuckyGear requires ItemAttributes {
#define BUFF_ID 'A06K'
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].dodge += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].dodge -= buf.bd.r0;
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.dodge += 0.03 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        UnitProp[buf.bd.target].dodge -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_MOROES_LUCKY_GEAR, action);
        RegisterSpellEffectResponse(SID_MOROES_LUCKY_GEAR, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
}
//! endzinc
