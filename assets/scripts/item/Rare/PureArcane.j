//! zinc
library PureArcane requires DamageSystem, BuffSystem {
    HandleTable ht;
    
    function damaged() {
        integer i;
        item ti;
        real amt;

        if (DamageResult.isHit == false) return;
        if (DamageResult.isPhyx == true) return;
        if (DamageResult.isCritical == false) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, SID_PURE_ARCANE) == true) return;

        amt = ItemExAttributes.getUnitAttributeValue(DamageResult.source, IATTR_MDC_ARCANE, 0.5, SCOPE_PREFIX);
        i = 0;
        while (i < 6) {
            ti = UnitItemInSlot(DamageResult.source, i);
            if (GetItemTypeId(ti) == ITID_PURE_ARCANE) {
                SetItemCharges(ti, GetItemCharges(ti) + 1);
                if (GetItemCharges(ti) == 3) {
                    DelayedDamageTarget(DamageResult.source, DamageResult.target, amt + UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower(), SpellData.inst(SID_PURE_ARCANE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedLight.atUnits("MFPB", DamageResult.source, DamageResult.target, 0.75);
                    AddTimedEffect.atUnit(ART_ELF_EXPLOSION, DamageResult.target, "origin", 1.0);
                    SetItemCharges(ti, 0);
                }
            }
            i += 1;
        }
        ti = null;
        SetUnitICD(DamageResult.source, SID_PURE_ARCANE, 2);
    }

    public function EquipedPureArcane(unit u, integer polar) {
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
