//! zinc
library Anathema requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasAnathema(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModLife(150 * fac);
        up.spellPower += 25 * fac;
        up.spellHaste += 0.05 * fac;
        up.spellCrit += 0.05 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDANATHEMA, action);
    }
}
//! endzinc
