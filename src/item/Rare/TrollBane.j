//! zinc
library TrollBane requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModAgi(15 * fac);
        up.ModAP(10 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_TROLL_BANE, action);
    }
}
//! endzinc
