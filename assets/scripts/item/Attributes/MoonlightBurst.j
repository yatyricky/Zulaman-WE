//! zinc
library MoonlightBurst requires DamageSystem, Math {
    HandleTable ht;

    function moonlightBurst(DelayTask dt) {
        integer i = 0;
        while (i < MobList.n) {
            if (IsPointInLinearShooter(GetUnitX(MobList.units[i]), GetUnitY(MobList.units[i]), GetUnitX(dt.u0), GetUnitY(dt.u0), dt.r1, 200.0, 900.0) == true) {
                DamageTarget(dt.u0, MobList.units[i], dt.r0, SpellData.inst(SID_MOONLIGHT_GREATSWORD_BURST, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            i += 1;
        }
    }

    function damaged() {
        real angle;
        DelayTask dt;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (GetRandomReal(0, 0.99999) > 0.1) return;
        if (IsUnitICD(DamageResult.source, SID_MOONLIGHT_GREATSWORD_BURST) == true) return;
        if (GetUnitStatePercent(DamageResult.source, UNIT_STATE_MANA, UNIT_STATE_MAX_MANA) < 5) return;

        // consumes mana
        ModUnitMana(DamageResult.source, 0.0 - GetUnitState(DamageResult.source, UNIT_STATE_MAX_MANA) * 0.05);
        // internal CD
        SetUnitICD(DamageResult.source, SID_MOONLIGHT_GREATSWORD_BURST, 10);
        // visual effect
        angle = GetAngle(GetUnitX(DamageResult.source), GetUnitY(DamageResult.source), GetUnitX(DamageResult.target), GetUnitY(DamageResult.target));
        VisualEffects.pierce(ART_GargoyleMissile, GetUnitX(DamageResult.source), GetUnitY(DamageResult.source), angle, 900, 1500, 2.2);
        // damage
        dt = DelayTask.create(moonlightBurst, 0.01);
        dt.r0 = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_MOONWAVE, SCOPE_PREFIX);
        dt.r0 += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 1.25;
        dt.r1 = angle;
        dt.u0 = DamageResult.source;
    }

    public function EquipedMoonlightBurst(unit u, integer polar) {
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
