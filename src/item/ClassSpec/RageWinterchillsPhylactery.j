//! zinc
library RageWinterchillsPhylactery requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasRageWinterchillsPhylactery(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModInt(10 * fac);
        up.spellCrit += 0.05 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDRAGEWINTERCHILLSPHYLACTERY, action);
    }
}
//! endzinc
