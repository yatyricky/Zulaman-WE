//! zinc
library BootsOfSlow requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModArmor(1 * fac);
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_BOOTS_OF_SLOW, action);
    }
}
//! endzinc
