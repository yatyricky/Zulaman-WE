//! zinc
library AttackStun requires StunUtils, DamageSystem {

    HandleTable ht;

    function damaged() {
        Buff buf;
        real newDmg;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, DUMMY_ATTACK_STUN) == true) return;
        if (GetRandomReal(0, 0.99999) >= 0.1) return;

        StunUnit(DamageResult.source, DamageResult.target, ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_STUN, SCOPE_PREFIX));
        SetUnitICD(DamageResult.source, DUMMY_ATTACK_STUN, 10);
    }

    public function EquipedAttackStun(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
