//! zinc
library RareShimmerWeed requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasRareShimmerWeed(unit u) -> boolean {
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
        up.spellPower += 25 * fac;
        up.ModAttackSpeed(10 * fac);
        up.spellHaste += 0.05 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDRARESHIMMERWEED, action);
    }
}
//! endzinc
