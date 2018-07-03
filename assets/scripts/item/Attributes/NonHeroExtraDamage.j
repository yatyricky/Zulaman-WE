//! zinc
library NonHeroExtraDamage requires DamageSystem {
    HandleTable ht;

    function onDamage() {
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitType(DamageResult.target, UNIT_TYPE_HERO) == true) return;
        DamageResult.amount = DamageResult.amount * (1 + ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_CRKILLER, SCOPE_PREFIX));
    }

    public function EquipedNonHeroExtraDamage(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterOnDamageEvent(onDamage);
    }

}
//! endzinc
