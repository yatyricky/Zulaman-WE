//! zinc
library Abomination requires DamageSystem, AggroSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function abominationDeath(unit u) {
        integer i;
        real amt;
        Buff buf;
        if (GetUnitTypeId(u) == UTID_ABOMINATION) {
            AddTimedEffect.atUnit(ART_ABOMINATION_EXPLOSION, u, "origin", 1.0);
            for (0 <= i< PlayerUnits.n) {
                if (GetDistance.units(u, PlayerUnits.units[i]) <= AbyssArchonGlobal.abominationAOE) {
                    amt = GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.25;
                    DamageTarget(u, PlayerUnits.units[i], amt, SpellData.inst(SID_SUMMON_ABOMINATION, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);

                    buf = Buff.cast(u, PlayerUnits.units[i], BID_SUMMON_ABOMINATION);
                    buf.bd.tick = -1;
                    buf.bd.interval = 10;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
                    buf.bd.r0 = 0.5;
                    if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_CRIPPLE_TARGET, buf, "origin");}
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }

            for (0 <= i< MobList.n) {
                if (!IsUnit(MobList.units[i], u) && GetDistance.units(u, MobList.units[i]) <= AbyssArchonGlobal.abominationAOE) {
                    amt = GetUnitState(MobList.units[i], UNIT_STATE_MAX_LIFE) * 0.05;
                    DamageTarget(u, MobList.units[i], amt, SpellData.inst(SID_SUMMON_ABOMINATION, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);

                    buf = Buff.cast(u, MobList.units[i], BID_SUMMON_ABOMINATION);
                    buf.bd.tick = -1;
                    buf.bd.interval = 10;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
                    buf.bd.r0 = 2;
                    if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_CRIPPLE_TARGET, buf, "origin");}
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                }
            }
        }
    }

    function doSummonAbomination(DelayTask dt) {
        unit u;
        if (IsInCombat() == true) {
            u = CreateUnit(Player(MOB_PID), UTID_ABOMINATION, 9772, 10029, 270);
            AddTimedEffect.atUnit(ART_DarkSummonTarget, u, "origin", 0.2);
            u = null;
        }
        SetDoodadAnimation(9769, 10396, 200, 'D031', false, "Stand", false);
    }

    function onCast() {
        DelayTask dt = DelayTask.create(doSummonAbomination, 5.0);
        SetDoodadAnimation(9769, 10396, 200, 'D031', false, "Stand Work", false);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_ABOMINATION, onCast);
        BuffType.register(BID_SUMMON_ABOMINATION, BUFF_PHYX, BUFF_NEG);
        RegisterUnitDeath(abominationDeath);
    }


}
//! endzinc
