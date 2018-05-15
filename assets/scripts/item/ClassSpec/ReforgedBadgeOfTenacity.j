//! zinc
library ReforgedBadgeOfTenacity requires BuffSystem, DamageSystem {
    HandleTable ht;

    public function EquipedReforgedBadgeOfTenacity(unit u, integer polar) {
        real amt;
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
        amt = ItemExAttributes.getUnitAttrValMax(u, IATTR_DR_CDR, SCOPE_PREFIX);
        BlzSetUnitAbilityCooldown(u, SID_SURVIVAL_INSTINCTS, GetUnitAbilityLevel(u, SID_SURVIVAL_INSTINCTS), 60 - amt);
    }

    function onInit() {
        ht = HandleTable.create();
    }

}
//! endzinc
