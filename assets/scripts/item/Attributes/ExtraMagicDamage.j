//! zinc
library ExtraMagicDamage requires Table, DamageSystem {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        DamageTarget(dt.u0, dt.u1, dt.r0, SpellData.inst(SID_EXTRA_MAGIC_DAMAGE, SCOPE_PREFIX + "damaged").name, false, false, false, WEAPON_TYPE_WHOKNOWS);
    }
    
    function damaged() {
        integer i = 0;
        item ti;
        real amt;
        DelayTask dt;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                amt = 0;
                while (i < 6) {
                    ti = UnitItemInSlot(DamageResult.source, i);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_MD, "ExtraMagicDamage_damaged");
                    }
                    i += 1;
                }
                ti = null;
                dt = DelayTask.create(extraDamageEffect, 0.03);
                dt.u0 = DamageResult.source;
                dt.u1 = DamageResult.target;
                dt.r0 = amt;
            }
        }
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
