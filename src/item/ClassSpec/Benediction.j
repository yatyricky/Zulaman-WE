//! zinc
library Benediction requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasBenediction(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModInt(10 * fac);
        up.ModLife(100 * fac);
        up.spellPower += 20 * fac;
        up.manaRegen += 5 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDBENEDICTION, action);
    }
}
//! endzinc
