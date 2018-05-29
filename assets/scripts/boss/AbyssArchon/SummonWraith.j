//! zinc
library Wraith requires UnitProperty, AggroSystem {

    timer wraithCheck;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
    }

    function checkRun() {
        NodeObject iter;
        unit wraith;
        integer j;
        Buff buf;
        iter = AbyssArchonGlobal.wraiths.head;
        while (iter != 0) {
            wraith = IntRefUnit(iter.data);
            for (0 <= j < PlayerUnits.n) {
                if (GetDistance.units(wraith, PlayerUnits.units[j]) <= AbyssArchonGlobal.wraithAOE) {
                    buf = Buff.cast(wraith, PlayerUnits.units[j], BID_SUMMON_WRAITH);
                    buf.bd.tick = -1;
                    buf.bd.interval = 0.4;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
                    buf.bd.r0 = 1.0;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }
            iter = iter.next;
        }
        wraith = null;
    }

    function wraithDeath(unit u) {
        integer ref;
        NodeObject iter;
        if (GetUnitTypeId(u) == UTID_WRAITH) {
            ref = -1;
            iter = AbyssArchonGlobal.wraiths.head;
            while (iter != 0) {
                if (u == IntRefUnit(iter.data)) {
                    ref = iter.data;
                } else {
                    iter = iter.next;
                }
            }
            if (ref == -1) {
                loge("wraith dead but was not pushed into list");
            } else {
                AbyssArchonGlobal.wraiths.removeNode(iter);
                Int2Unit(ref);
                if (AbyssArchonGlobal.wraiths.count() == 0) {
                    PauseTimer(wraithCheck);
                }
            }
        }
    }

    function AddInvul(DelayTask dt) {
        UnitProp.inst(dt.u0, SCOPE_PREFIX).damageTaken = -5.0;
        UnitProp.inst(dt.u0, SCOPE_PREFIX).spellTaken = -5.0;
    }

    function doSummonWraith(DelayTask dt) {
        unit u;
        if (IsInCombat() == true) {
            u = CreateUnit(Player(MOB_PID), UTID_WRAITH, 9788, 9467, 180);
            AddTimedEffect.atUnit(ART_DarkSummonTarget, u, "origin", 0.2);
            if (AbyssArchonGlobal.wraiths.count() == 0) {
                TimerStart(wraithCheck, 0.34, true, function checkRun);
            }
            DelayTask.create(AddInvul, 0.09).u0 = u;
            AbyssArchonGlobal.wraiths.push(Unit2Int(u));
            u = null;
        }
        SetDoodadAnimation(9788, 9467, 200, 'D032', false, "Stand", false);
    }

    function onCast() {
        DelayTask dt = DelayTask.create(doSummonWraith, 5.0);
        SetDoodadAnimation(9788, 9467, 200, 'D032', false, "Stand Work", false);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_WRAITH, onCast);
        BuffType.register(BID_SUMMON_WRAITH, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(wraithDeath);
        wraithCheck = CreateTimer();
        AbyssArchonGlobal.wraiths = ListObject.create();
    }

}
//! endzinc
