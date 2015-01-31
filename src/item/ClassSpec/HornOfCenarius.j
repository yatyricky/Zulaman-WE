//! zinc
library HornOfCenarius requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasHornOfCenarius(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(8 * fac);
        up.ModAgi(8 * fac);
        up.ModInt(8 * fac);
        up.ModLife(75 * fac);
        up.ModMana(100 * fac);
        up.spellPower += 22 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDHORNOFCENARIUS, action);
    }
}
//! endzinc
