//! zinc
library GoreHowl requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(20 * fac);
        up.ModAP(20 * fac);
        up.attackCrit += 0.07 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_GORE_HOWL, action);
    }
}
//! endzinc
