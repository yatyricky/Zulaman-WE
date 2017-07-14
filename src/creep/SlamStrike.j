//! zinc
library SlamStrike {

    function gargantuanDamaged(unit u) {
        integer i;
        if (GetUnitTypeId(DamageResult.source) == UTID_GARGANTUAN && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            for (0 <= i < PlayerUnits.n) {
                if (GetDistance.unitCoord(PlayerUnits.units[i], GetUnitX(u), GetUnitX(y)) < 250.0) {
                    DamageTarget(DamageResult.source, PlayerUnits.units[i], DamageResult.amount, SpellData[SID_SLAM_STRIKE].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
                }
            }
        }
    }

    function onInit() {
        RegisterDamagedEvent(gargantuanDamaged);
    }
}
//! endzinc
