//! zinc
library NetherBreath {
/*
players in cone takes damage and takes extra magical damage
magical negative effect
*/
#define AOE 400.0
#define ANGLE 75.0

    function onEffect(Buff buf) { 
        UnitProp[buf.bd.target].spellTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
    }
	
	function onCast() {
		integer i;
		real fcaster = GetUnitFacing(SpellEvent.CastingUnit);
		Buff buf;
		for (0 <= i < PlayerUnits.n) {
			if (GetAngleDiffDeg(fcaster, GetUnitFacing(PlayerUnits.units[i])) <= ANGLE * 0.5 && GetDistance.units(SpellEvent.CastingUnit, PlayerUnits.units[i]) <= AOE) {
		        buf = Buff.cast(SpellEvent.CastingUnit, PlayerUnits.units[i], BID);
		        buf.bd.tick = -1;
		        buf.bd.interval = 12;
		        UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
		        buf.bd.r0 = 1.0;
		        buf.bd.boe = onEffect;
		        buf.bd.bor = onRemove;
		        buf.run();
			}
		}

		CreateUnit(Player(0), UTID, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), GetUnitFacing(SpellEvent.CastingUnit) - ANGLE * 0.5);
		CreateUnit(Player(0), UTID, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), GetUnitFacing(SpellEvent.CastingUnit));
		CreateUnit(Player(0), UTID, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), GetUnitFacing(SpellEvent.CastingUnit) + ANGLE * 0.5);
	}

	function onInit() {
		BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SIDPAIN, onCast);
	}
}
//! endzinc
 