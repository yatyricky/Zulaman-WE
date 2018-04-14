//! zinc
library FoulTentacle {
constant real WRAITH_CHECK_INTERVAL = 0.34;

    timer wraithCheck;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
    }

    function checkRun() {
        integer i, j;
        Buff buf;
        for (0 <= i < SummonedWraiths.size()) {
            for (0 <= j < PlayerUnits.n) {
                if (GetDistance.units(SummonedWraiths.get(i), PlayerUnits.units[j]) <= AbyssArchonGlobalConst.wraithAOE) {
                    buf = Buff.cast(SummonedWraiths.get(i), PlayerUnits.units[j], BID);
                    buf.bd.tick = -1;
                    buf.bd.interval = WRAITH_CHECK_INTERVAL + 0.1;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
                    buf.bd.r0 = 1.0;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }
        }
    }

    function wraithDeath(unit u) {
        if (GetUnitTypeId(u) == UTID) {
            SummonedWraiths.remove(u);
            if (SummonedWraiths.size() == 0) {
                PauseTimer(wraithCheck);
            }
        }
    }

    function onCast() {
        if (SummonedWraiths.size() == 0) {
            TimerStart(wraithCheck, WRAITH_CHECK_INTERVAL, true, function checkRun);
        }
        SummonedWraiths.add(CreateUnit(Player(MOB_PID), UTID, AbyssArchonGlobalConst.summonX, AbyssArchonGlobalConst.summonY, GetRandomReal(0, 359)));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID, onCast);
        BuffType.register(BID, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(wraithDeath);
        wraithCheck = CreateTimer();
    }

}
//! endzinc
