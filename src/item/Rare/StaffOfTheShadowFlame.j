//! zinc
library StaffOfTheShadowFlame requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModInt(10 * fac);
        up.spellPower += 15 * fac;
        up.spellCrit += 0.07 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_STAFF_OF_THE_SHADOW_FLAME, action);
    }
}
//! endzinc
