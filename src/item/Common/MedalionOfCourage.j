//! zinc
library MedalionOfCourage requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(4 * fac);
        up.ModInt(4 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_MEDALION_OF_COURAGE, action);
    }
}
//! endzinc
