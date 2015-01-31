//! zinc
library Viskag requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAgi(15 * fac);
        up.ModAP(20 * fac);
        up.ModAttackSpeed(14 * fac);
        up.ll += 0.08 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_VISKAG, action);
    }
}
//! endzinc
