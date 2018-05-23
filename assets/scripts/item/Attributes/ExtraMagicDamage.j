//! zinc
library ExtraMagicDamage requires Table, DamageSystem {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        DamageTarget(dt.u0, dt.u1, dt.r0, SpellData.inst(SID_EXTRA_MAGIC_DAMAGE, SCOPE_PREFIX + "damaged").name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
    }
    
    function damaged() {
        DelayTask dt;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;

        dt = DelayTask.create(extraDamageEffect, 0.03);
        dt.u0 = DamageResult.source;
        dt.u1 = DamageResult.target;
        dt.r0 = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_MD, SCOPE_PREFIX);
    }

    public function EquipedExtraMagicDamage(unit u, integer polar) {
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
