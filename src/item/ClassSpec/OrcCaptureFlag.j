//! zinc
library OrcCaptureFlag requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasOrcCaptureFlag(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModAgi(10 * fac);
        up.ModAP(15 * fac);
        up.attackCrit += 0.04 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDORCCAPTUREFLAG, action);
    }
}
//! endzinc
