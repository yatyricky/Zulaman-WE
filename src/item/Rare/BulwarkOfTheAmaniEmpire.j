//! zinc
library BulwarkOfTheAmaniEmpire requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModArmor(3 * fac);
        up.ModStr(10 * fac);
        up.ModLife(170 * fac);
        up.blockPoint += 28 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_BULWARK_OF_THE_AMANI_EMPIRE, action);
    }
}
//! endzinc
