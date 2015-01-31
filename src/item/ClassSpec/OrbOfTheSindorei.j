//! zinc
library OrbOfTheSindorei requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    public function HasOrbOfTheSindorei(unit u) -> boolean {
        if (!ht.exists(u)) {
            return false;
        } else {
            return ht[u] > 0;
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModLife(125 * fac);
        up.spellPower += 25.0 * fac;
	    up.blockRate += 0.07 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDORBOFTHESINDOREI, action);
    }
}
//! endzinc
