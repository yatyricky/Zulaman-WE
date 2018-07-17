//! zinc
library MagicChainLightning requires Table, ChainLightning {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        ChainLightning.start(dt.u0, dt.u1, SpellData.inst(SID_INFINITY, "MCL").name, "CLPB", "CLSB", dt.r0, 3, 0.75);
    }

    function damaged() {
        real amt;
        DelayTask dt;

        if (DamageResult.isHit == false) return;
        if (DamageResult.wasDirect == false) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (GetRandomReal(0, 0.999) >= 0.1) return;
        if (IsUnitICD(DamageResult.source, SID_INFINITY) == true) return;

        amt = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_MD_CHAIN, SCOPE_PREFIX);
        amt += UnitProp.inst(DamageResult.source, SCOPE_PREFIX).SpellPower() * 0.2;

        dt = DelayTask.create(extraDamageEffect, 0.03);
        dt.u0 = DamageResult.source;
        dt.u1 = DamageResult.target;
        dt.r0 = amt;

        SetUnitICD(DamageResult.source, SID_INFINITY, 3);
    }

    public function EquipedMagicChainLightning(unit u, integer polar) {
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
