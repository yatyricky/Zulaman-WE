//! zinc
library CruelColossusBladeOfQuickness requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAP(50 * fac);
        up.ModAttackSpeed(30 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_CRUEL_COLOSSUS_BLADE_OF_QUICKNESS, action);
    }
}
//! endzinc
