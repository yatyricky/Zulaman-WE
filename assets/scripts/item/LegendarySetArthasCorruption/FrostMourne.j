//! zinc
library FrostMourne requires ItemAttributes, ArthassCorruption {
    HandleTable ht2;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModStr(15 * fac);
        up.ll += 0.11 * fac;
        
        RefreshArthassCorruption(u);
    }

    function action1(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModStr(15 * fac);
        up.ll += 0.11 * fac;
        up.ml += 0.09 * fac;
        
        RefreshArthassCorruption(u);
    }

    function action2(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModStr(15 * fac);
        up.ll += 0.11 * fac;
        up.ml += 0.09 * fac;
        
        if (!ht2.exists(u)) {ht2[u] = 0;}
        ht2[u] = ht2[u] + fac;
        
        RefreshArthassCorruption(u);
    }

    function onInit() {
        ht2 = HandleTable.create();
    }
}
//! endzinc
