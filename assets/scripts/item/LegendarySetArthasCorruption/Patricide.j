//! zinc
library Patricide requires ItemAttributes, ArthassCorruption {
    HandleTable ht, ht2;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAP(30 * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        RefreshArthassCorruption(u);
    }

    function action1(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAP(30 * fac);
        up.ModAttackSpeed(10 * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        RefreshArthassCorruption(u);
    }

    function action2(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAP(30 * fac);
        up.ModAttackSpeed(10 * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        if (!ht2.exists(u)) {ht2[u] = 0;}
        ht2[u] = ht2[u] + fac;
        
        RefreshArthassCorruption(u);
    }

    function onInit() {
        ht = HandleTable.create();
        ht2 = HandleTable.create();
    }
}
//! endzinc
