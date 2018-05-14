//! zinc
library WindForce requires ForcedMovement {
    HandleTable ht;
    
    function damaged() {
        real chance;
        real dis, dx, dy;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                chance = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_WF, SCOPE_PREFIX);
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
