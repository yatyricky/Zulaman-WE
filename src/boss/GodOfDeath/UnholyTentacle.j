//! zinc
library UnholyTentacle {
	
    function onCast() {
    	CreateUnit(Player(MOB_PID), UTID, x, y, r);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
    }
}
//! endzinc
