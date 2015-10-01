//! zinc
library Wraith requires UnitProperty {
#define WRAITH_CHECK_INTERVAL 0.34

	timer wraithCheck;

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].healTaken += buf.bd.r0;
    }

	function checkRun() {
		integer i, j;
		Buff buf;
		for (0 <= i < SummonedWraiths.size()) {
			for (0 <= j < PlayerUnits.n) {
				if (GetDistance.units(SummonedWraiths.get(i), PlayerUnits.units[j]) <= AbyssArchonGlobal.wraithAOE) {
		            buf = Buff.cast(SummonedWraiths.get(i), PlayerUnits.units[j], BID_SUMMON_WRAITH);
		            buf.bd.tick = -1;
		            buf.bd.interval = WRAITH_CHECK_INTERVAL + 0.1;
		            UnitProp[buf.bd.target].healTaken += buf.bd.r0;
		            buf.bd.r0 = 1.0;
		            buf.bd.boe = onEffect;
		            buf.bd.bor = onRemove;
		            buf.run();
				}
			}
		}
	}

	function wraithDeath(unit u) {
		if (GetUnitTypeId(u) == UTID_WRAITH) {
			SummonedWraiths.remove(u);
			if (SummonedWraiths.size() == 0) {
				PauseTimer(wraithCheck);
			}
		}
	}

	function AddInvul(DelayTask dt) {
		UnitProp[dt.u0].damageTaken = -5.0;
		UnitProp[dt.u0].spellTaken = -5.0;
	}

	function onCast() {
		unit u;
		Point p = AbyssArchonGlobal.getSummonPoint();
		if (SummonedWraiths.size() == 0) {
			TimerStart(wraithCheck, WRAITH_CHECK_INTERVAL, true, function checkRun);
		}
		u = CreateUnit(Player(MOB_PID), UTID_WRAITH, p.x, p.y, GetRandomReal(0, 359));
		DelayTask.create(AddInvul, 0.09).u0 = u;
		SummonedWraiths.add(u);
		p.destroy();
	}

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_WRAITH, onCast);
        BuffType.register(BID_SUMMON_WRAITH, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(wraithDeath);
        wraithCheck = CreateTimer();
    }
#undef WRAITH_CHECK_INTERVAL
}
//! endzinc
