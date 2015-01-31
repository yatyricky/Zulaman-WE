//! zinc
library RhokDelar requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasRhokDelar(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAgi(10 * fac);
        up.ModAP(20 * fac);
        up.attackCrit += 0.08 * fac;
        up.ModSpeed(30 * fac);
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDRHOKDELAR, action);
    }
}
//! endzinc
