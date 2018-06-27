//! zinc
library Bash requires StunUtils, DamageSystem {

    function damaged() {
        if (GetUnitTypeId(DamageResult.source) != UTID_THURG) return;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (GetRandomReal(0, 0.999) >=  0.2) return;

        StunUnit(DamageResult.source, DamageResult.target, 1.0);
    }

    function onInit() {
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
