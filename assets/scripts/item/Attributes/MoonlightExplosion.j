//! zinc
library MoonlightExplosion requires DamageSystem {
    HandleTable ht;
    HandleTable counter;

    function moonlightExp(DelayTask dt) {
        integer i = 0;
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], dt.u1) <= 250.0) {
                DamageTarget(dt.u0, MobList.units[i], dt.r0, SpellData.inst(SID_MOONLIGHT_GREATSWORD_EXPLOSION, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            i += 1;
        }
    }
    
    function damaged() {
        integer i;
        DelayTask dt;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;

        if (counter.exists(DamageResult.source) == false) {
            counter[DamageResult.source] = 0;
        }
        counter[DamageResult.source] = counter[DamageResult.source] + 1;
        if (counter[DamageResult.source] == 3) {
            counter[DamageResult.source] = 0;
            if (GetUnitStatePercent(DamageResult.source, UNIT_STATE_MANA, UNIT_STATE_MAX_MANA) >= 5) {
                // start effect
                // consumes mana
                ModUnitMana(DamageResult.source, 0.0 - GetUnitState(DamageResult.source, UNIT_STATE_MAX_MANA) * 0.05);
                // visual
                AddTimedEffect.atUnit(ART_WISP_EXPLODE, DamageResult.target, "origin", 1.0);
                // damage
                dt = DelayTask.create(moonlightExp, 0.01);
                dt.r0 = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_3ATK_MOONEXP, SCOPE_PREFIX);
                dt.r0 += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.1;
                dt.u0 = DamageResult.source;
                dt.u1 = DamageResult.target;
            }
        }
    }

    public function EquipedMoonlightExplosion(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        counter = HandleTable.create();
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
