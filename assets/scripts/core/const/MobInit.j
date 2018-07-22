//! zinc
library MobInit requires Table, BuffSystem, Patrol, NefUnion, WarlockGlobal, StunUtils, ChampionMonster {
constant integer MOBINIT_RESPAWN_L = 600;
constant integer MOBINIT_RESPAWN_H = 720;

    private HandleTable idTable;
    private integer numMobs;
    private integer allCreepData[NUMBER_OF_BOSSES][500];
    private integer allCreepDataN[NUMBER_OF_BOSSES];
    private integer allowArea = 0;

    function cancelForm(DelayTask dt) {
        IssueImmediateOrderById(dt.u0, OID_UNBEARFORM);
    }
    
    function cancelStun(DelayTask dt) {
        RemoveStun(dt.u0);
    }

    public function ResetMob(unit u) {
        integer id = idTable[u];
        BuffSlot[u].removeAllBuff();
        if (UnitProp.inst(u, SCOPE_PREFIX).Stunned()) {
            // print("cancel stun");
            DelayTask.create(cancelStun, 0.5).u0 = u;
        }

        if (GetUnitTypeId(u) == UTID_ARCH_TINKER_MORPH || GetUnitTypeId(u) == UTID_TIDE_BARON_WATER) {
            DelayTask.create(cancelForm, 1.0).u0 = u;
        }
        
        if (GetUnitTypeId(u) == UTID_WARLOCK) {
            ResetFireRunes();
        }

        if (GetUnitTypeId(u) == UTID_PIT_ARCHON) {
            AbyssArchonGlobal.reset();
        }

        if (GetUnitTypeId(u) == UTID_FEL_GUARD) {
            FelGuardsGlobals.reset();
        }
        
        IssueImmediateOrderById(u, OID_STOP);
        PauseUnit(u, true);
        SetUnitX(u, mobInfo[id].x);
        SetUnitY(u, mobInfo[id].y);
        SetUnitFacing(u, mobInfo[id].f);
        SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE));
        SetUnitState(u, UNIT_STATE_MANA, GetUnitState(u, UNIT_STATE_MAX_MANA));
        PauseUnit(u, false);
    }
    
    private struct mobInfo[] {
        integer utid;
        real x, y, f;
        unit u;
        integer respawnCounter;
        integer respawning;
        integer respawnTime;
        integer respawnTimeVar;
        Patroller p;
    }

    function championizeUnit(DelayTask dt) {
        if (RectContainsUnit(gg_rct_FirstChampion, dt.u0) == true) {
            ChampionizeLesser(dt.u0);
        } else {
            ChampionizeRandom(dt.u0);
        }
    }

    public function MobInitAllowArea(integer a) {
        integer i = 0;
        mobInfo mi;
        DelayTask dt;
        while (i < allCreepDataN[a - 1]) {
            mi = mobInfo[allCreepData[a - 1][i]];
            mi.u = CreateUnit(Player(MOB_PID), mi.utid, mi.x, mi.y, mi.f);
            idTable[mi.u] = mi;

            if (IsUnitChampion(mi.u) == true) {
                DelayTask.create(championizeUnit, 0.9).u0 = mi.u;
            }

            if (mi.utid == UTID_FEL_GUARD) {
                FelGuardsGlobals.bossGuard = mi.u;
            }
            if (mi.utid == UTID_FEL_DEFENDER) {
                FelGuardsGlobals.bossDefender = mi.u;
            }
            i += 1;
        }
        allowArea = a;
    }
    
    private function onInit() {
        numMobs = 0;
        idTable = HandleTable.create();

        // Mob init
        TimerStart(CreateTimer(), 0.15, false, function() {
            group g;
            unit tu;
            integer pid;
            integer i = 0;
            Patroller p;
            DestroyTimer(GetExpiredTimer());

            while (i < 8) {
                allCreepDataN[i] = 0;
                i += 1;
            }

            g = NewGroup();
            GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
            tu = FirstOfGroup(g);
            while (tu != null) {
                pid = GetPidofu(tu) - 16;
                if (pid >= 0) {
                    RemoveUnit(tu);
                    // u = CreateUnit(Player(10), GetUnitTypeId(tu), GetUnitX(tu), GetUnitY(tu), GetUnitFacing(tu));
                    mobInfo[numMobs].x = GetUnitX(tu); 
                    mobInfo[numMobs].y = GetUnitY(tu); 
                    mobInfo[numMobs].f = GetUnitFacing(tu); 
                    mobInfo[numMobs].utid = GetUnitTypeId(tu);
                    mobInfo[numMobs].u = null;
                    mobInfo[numMobs].respawnCounter = 0;
                    mobInfo[numMobs].respawning = -1;
                    mobInfo[numMobs].respawnTime = MOBINIT_RESPAWN_L;
                    mobInfo[numMobs].respawnTimeVar = MOBINIT_RESPAWN_H;
                    mobInfo[numMobs].p = 0;

                    allCreepData[pid][allCreepDataN[pid]] = numMobs;
                    allCreepDataN[pid] += 1;

                    numMobs = numMobs + 1;
                }

                GroupRemoveUnit(g, tu);
                tu = FirstOfGroup(g);
            }
            ReleaseGroup(g);
            g = null;
            tu = null;
        });
    }

}
//! endzinc
