//! zinc
library GoblinRocketBootsLimitedEdition requires ItemAttributes {
#define BUFF_ID 'A07A'
    //HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 300;
        buf.bd.boe = oneffect;
        buf.bd.bor = onremove;
        buf.run();
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModLife(120 * fac);
        up.ModMana(175 * fac);
        up.dodge += 0.01 * fac;
        up.ModSpeed(20 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, action);
        RegisterSpellEffectResponse(SID_GOBLIN_ROCKET_BOOTS_LIMITED_EDITION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef BUFF_ID
}
//! endzinc
