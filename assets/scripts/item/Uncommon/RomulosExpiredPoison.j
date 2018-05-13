//! zinc
library RomulosExpiredPoison requires DamageSystem {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        DamageTarget(dt.u0, dt.u1, dt.r0, SpellData.inst(SID_ROMULOS_EXPIRED_POISION, SCOPE_PREFIX + "damaged").name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 0.5);
    }

    function damaged() {
        item ti;
        integer ii;
        real amt;
        DelayTask dt;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                if (GetRandomInt(0, 99) < 25) {
                    amt = 0;
                    ii = 0;
                    while (ii < 6) {
                        ti = UnitItemInSlot(SpellEvent.CastingUnit, ii);
                        if (ti != null) {
                            amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_MDC, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX));
                        }
                        ii += 1;
                    }
                    ti = null;

                    dt = DelayTask.create(extraDamageEffect, 0.03);
                    dt.u0 = DamageResult.source;
                    dt.u1 = DamageResult.target;
                    dt.r0 = amt;
                }
            }
        }
    }

    public function EquipedChanceMagicDamage(unit u, integer polar) {
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
