//! zinc
library The21Ring requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(21 * fac);
        up.ModAgi(21 * fac);
        up.ModInt(21 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_THE_21_RING, action);
    }
}
//! endzinc
