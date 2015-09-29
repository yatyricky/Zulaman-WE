//! zinc
library Abomination requires DamageSystem {

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

	function abominationDeath(unit u) {
		integer i;
		real amt;
		Buff buf;
		if (GetUnitTypeId(u) == UTID) {
			for (0 <= i< PlayerUnits.n) {
				if (GetDistance.units(u, PlayerUnits.units[i]) <= AbyssArchonGlobalConst.abominationAOE) {
					amt = GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.05;
					DamageTarget(u, PlayerUnits.units[i], amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);

		            buf = Buff.cast(u, PlayerUnits.units[i], BID);
		            buf.bd.tick = -1;
		            buf.bd.interval = 10;
		            UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
		            buf.bd.r0 = 0.5;
		            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "origin");}
		            buf.bd.boe = onEffect;
		            buf.bd.bor = onRemove;
		            buf.run();
		        }
			}

			for (0 <= i< MobList.n) {
				if (!IsUnit(MobList.units[i], u) && GetDistance.units(u, MobList.units[i]) <= AbyssArchonGlobalConst.abominationAOE) {
					amt = GetUnitState(MobList.units[i], UNIT_STATE_MAX_LIFE) * 0.05;
					DamageTarget(u, MobList.units[i], amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);

		            buf = Buff.cast(u, MobList.units[i], BID);
		            buf.bd.tick = -1;
		            buf.bd.interval = 10;
		            UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
		            buf.bd.r0 = 0.5;
		            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "origin");}
		            buf.bd.boe = onEffect;
		            buf.bd.bor = onRemove;
		            buf.run();
		        }
			}
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
