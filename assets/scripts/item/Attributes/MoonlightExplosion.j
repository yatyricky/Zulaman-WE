//! zinc
library MoonlightExplosion requires DamageSystem {
    HandleTable ht;
    HandleTable counter;
    
    function damaged() {
        integer i;
        real dmg;
        unit target;
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
                dmg = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_3ATK_MOONEXP, SCOPE_PREFIX);
                dmg += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.25;
                target = DamageResult.target;
                i = 0;
                while (i < MobList.n) {
                    if (GetDistance.units2d(MobList.units[i], target) <= 250.0) {
                        DamageTarget(DamageResult.source, MobList.units[i], dmg, SpellData.inst(SID_MOONLIGHT_GREATSWORD_EXPLOSION, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
                    }
                    i += 1;
                }
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
