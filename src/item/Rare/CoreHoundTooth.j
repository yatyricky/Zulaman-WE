//! zinc
library CoreHoundTooth requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModLife(100 * fac);
        up.ModAP(30 * fac);
        up.ModAttackSpeed(10 * fac);
        up.attackCrit += 0.05 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_CORE_HOUND_TOOTH, action);
    }
}
//! endzinc
