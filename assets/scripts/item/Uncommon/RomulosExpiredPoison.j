//! zinc
library RomulosExpiredPoison requires DamageSystem {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        DamageTarget(dt.u0, dt.u1, dt.r0, SpellData.inst(SID_ROMULOS_EXPIRED_POISION, SCOPE_PREFIX + "damaged").name, true, true, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 0.5);
    }

    function damaged() {
        real amt;
        DelayTask dt;
        UnitProp up;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                if (GetRandomInt(0, 99) < 25) {
                    up = UnitProp.inst(DamageResult.source, SCOPE_PREFIX);
                    amt = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_MDC, SCOPE_PREFIX);
                    amt += up.AttackPower() * 0.5;
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
