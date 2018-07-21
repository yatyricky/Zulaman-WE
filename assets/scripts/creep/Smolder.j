//! zinc
library Smolder requires DamageSystem {

    unit towers[];
    integer towersN;
    timer tm;

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DummyDamageTarget(p.target, p.r0, SpellData.inst(SID_SMOLDER, SCOPE_PREFIX).name);
            return true;
        }
    }

    function check() {
        Projectile p;
        integer i = 0;
        integer j = 0;
        unit tu;
        while (j < towersN) {
            GroupUnitsInArea(ENUM_GROUP, GetUnitX(towers[j]), GetUnitY(towers[j]), 2000);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                GroupRemoveUnit(ENUM_GROUP, tu);
                if (!IsUnitDummy(tu) && !IsUnitDead(tu) && GetPidofu(tu) < NUMBER_OF_MAX_PLAYERS) {
                    p = Projectile.create();
                    p.caster = towers[j];
                    p.target = tu;
                    p.path = ART_BREATH_OF_FIRE_DAMAGE;
                    p.pr = onhit;
                    p.speed = 900;
                    p.r0 = GetUnitState(tu, UNIT_STATE_MAX_LIFE) * 0.05;
                    p.launch();
                }
                tu = FirstOfGroup(ENUM_GROUP);
            }
            tu = null;
            j += 1;
        }
    }

    function smolderingTowerEnter(unit u) {
        if (GetUnitTypeId(u) == UTID_SMOLDERING_TOWER) {
            // add tower
            towers[towersN] = u;
            towersN += 1;
            if (towersN == 1) {
                tm = NewTimer();
                TimerStart(tm, 1.0, true, function check);
            }
        }
    }

    function smolderingTowerDeath(unit u) {
        integer i;
        integer s = -1;
        if (GetUnitTypeId(u) == UTID_SMOLDERING_TOWER) {
            // remove tower
            i = 0;
            while (i < towersN && s == -1) {
                if (towers[i] == u) {
                    s = i;
                }
                i += 1;
            }
            if (s == -1) {
                print("[ERR]cannot find correct smoldering tower!");
            } else {
                towersN -= 1;
                towers[s] = towers[towersN];
                towers[towersN] = null;
                if (towersN == 0) {
                    ReleaseTimer(tm);
                }
            }
        }
    }

    function onInit() {
        RegisterUnitEnterMap(smolderingTowerEnter);
        RegisterUnitDeath(smolderingTowerDeath);
        towersN = 0;
    }

}
//! endzinc
