//! zinc
library ConvertAttackMagic requires Table, DamageSystem {
    HandleTable ht;

    function onDamaging() {
        if (DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                DamageResult.wasDodgable = false;
                DamageResult.isPhyx = false;
            }
        }
    }

    public function EquipedConvertAttackMagic(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterOnDamageEvent(onDamaging);
    }

}
//! endzinc
