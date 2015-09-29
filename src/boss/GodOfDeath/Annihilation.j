//! zinc
library Annihilation {
#define ART "zxczxc"

    function onCast() {
    	integer i;
    	for (0 <= i < PlayerUnits.n) {
    		KillUnit(PlayerUnits.units[i]);
    		AddTimedEffect.atUnit(ART, PlayerUnits.units[i], "origin", 1.0);
    	}
    }

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
    }
#undef ART
}
//! endzinc
