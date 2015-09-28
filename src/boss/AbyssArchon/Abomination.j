//! zinc
library Abomination {

	struct Abomination {
		static method start(unit caster) {
			
		}
	}
	

	function abominationDeath(unit u) {
		integer i;
		if (GetUnitTypeId(u) == UTID) {
			Abomination.start(u);
		}
	}

	function onCast() {
		CreateUnit(Player(MOB_PID), UTID, AbyssArchonGlobalConst.summonX, AbyssArchonGlobalConst.summonY, GetRandomReal(0, 359));
	}

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
        BuffType.register(BID, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(abominationDeath);
    }
}
//! endzinc
