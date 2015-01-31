//! zinc
library RunedBracers requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModLife(75 * fac);
        up.spellTaken -= 0.1 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_RUNED_BRACERS, action);
    }
}
//! endzinc
