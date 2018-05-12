//! zinc
library MagicChainLightning requires Table, ChainLightning {
    HandleTable ht;

    function extraDamageEffect(DelayTask dt) {
        ChainLightning.start(dt.u0, dt.u1, SpellData.inst(SID_INFINITY, "MCL").name, "CLPB", "CLSB", dt.r0, 3, 0.75);
    }

    function damaged() {
        integer ii;
        item ti;
        real amt;
        DelayTask dt;
        if (DamageResult.isHit == true && DamageResult.isPhyx == false && DamageResult.wasDirect == true) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0 && GetRandomReal(0, 0.999) < 0.1) {
                amt = 0;
                ii = 0;
                while (ii < 6) {
                    ti = UnitItemInSlot(DamageResult.source, ii);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_MD_CHAIN, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX));
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
