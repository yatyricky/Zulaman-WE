//! zinc
library DeterminationOfVengeance requires ItemAttributes, ArthassCorruption {
    //HandleTable ht;

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAgi(15 * fac);
        up.ModLife(100 * fac);
        up.damageTaken -= 0.07 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
        RefreshArthassCorruption(u);
    }

    function action1(unit u, item it, integer fac) {
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        up.ModAgi(15 * fac);
        up.ModLife(100 * fac);
        up.damageTaken -= 0.07 * fac;
        up.blockRate += 0.1 * fac;
        //if (!ht.exists(u)) {ht[u] = 0;}
        //ht[u] = ht[u] + fac;
        RefreshArthassCorruption(u);
    }

    function onInit() {
        //ht = HandleTable.create();
    }
}
//! endzinc
