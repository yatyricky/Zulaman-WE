//! zinc
library AransSoothingAgate requires ItemAttributes {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModInt(8 * fac);
        up.spellPower += 10 * fac;
        up.spellHaste += 0.05 * fac;
        up.manaRegen += 3 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
    }

    function onInit() {
        //ht = HandleTable.create();
        RegisterItemPropMod(ITID_ARANS_SOOTHING_AGATE, action);
    }
}
//! endzinc
