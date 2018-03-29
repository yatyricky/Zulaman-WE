//! zinc
library Annihilation {

    function onCast() {
        integer i;
        for (0 <= i < PlayerUnits.n) {
            KillUnit(PlayerUnits.units[i]);
            AddTimedEffect.atUnit(ART_BLOOD_LUST_LEFT, PlayerUnits.units[i], "origin", 1.0);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ANNIHILATION, onCast);
    }

}
//! endzinc
