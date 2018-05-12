//! zinc
library WindForce requires ForcedMovement {
    HandleTable ht;
    
    function damaged() {
        real chance;
        real dis, dx, dy;
        integer ii;
        item ti;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                chance = 0;
                ii = 0;
                while (ii < 6) {
                    ti = UnitItemInSlot(DamageResult.source, ii);
                    if (ti != null) {
                        chance += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_WF, SCOPE_PREFIX + "damaged") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "damaged2") * 0.16);
                    }
                    ii += 1;
                }
                ti = null;
                // take effect
                if (GetRandomReal(0.0, 0.999) < chance) {
                    dis = GetDistance.units(DamageResult.target, DamageResult.source);
                    dx = (GetUnitX(DamageResult.target) - GetUnitX(DamageResult.source)) * 24.0 / dis;
                    dy = (GetUnitY(DamageResult.target) - GetUnitY(DamageResult.source)) * 24.0 / dis;
                    ForceMoveUnitPolar(DamageResult.target, dx, dy, 5, -0.07);
                }
            }
        }
    }

    public function EquipedWindforce(unit u, integer polar) {
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
