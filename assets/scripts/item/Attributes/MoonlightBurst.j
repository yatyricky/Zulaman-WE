//! zinc
library MoonlightBurst requires DamageSystem, Math {
    HandleTable ht;

    function damaged() {
        real angle, amt;
        integer i;
        unit source;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        // if (GetRandomReal(0, 0.99999) < 0.1) return;
        // if (IsUnitICD(DamageResult.source, SID_MOONLIGHT_GREATSWORD_BURST) == true) return;
        if (GetUnitStatePercent(DamageResult.source, UNIT_STATE_MANA, UNIT_STATE_MAX_MANA) < 5) return;

        // consumes mana
        ModUnitMana(DamageResult.source, 0.0 - GetUnitState(DamageResult.source, UNIT_STATE_MAX_MANA) * 0.05);
        // internal CD
        SetUnitICD(DamageResult.source, SID_MOONLIGHT_GREATSWORD_BURST, 15);
        // visual effect
        angle = GetAngle(GetUnitX(DamageResult.source), GetUnitY(DamageResult.source), GetUnitX(DamageResult.target), GetUnitY(DamageResult.target));
        logi(R2S(angle));
        AddTimedEffect.atPos(ART_StarfallCaster, GetUnitX(DamageResult.target), GetUnitY(DamageResult.target), GetUnitZ(DamageResult.target) + 240.0, 0.5, 1.0).setPitch(angle + bj_PI * 0.5).setYaw(bj_PI * 0.5);
        // damage
        amt = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_MOONWAVE, SCOPE_PREFIX);
        amt += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.4;
        source = DamageResult.source;
        i = 0;
        while (i < MobList.n) {
            if (IsPointInLinearShooter(GetUnitX(MobList.units[i]), GetUnitY(MobList.units[i]), GetUnitX(source), GetUnitY(source), angle, 128.0, 600.0) == true) {
                DamageTarget(source, MobList.units[i], amt, SpellData.inst(SID_MOONLIGHT_GREATSWORD_BURST, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            i += 1;
        }
        source = null;
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
