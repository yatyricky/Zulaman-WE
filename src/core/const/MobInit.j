//! zinc
library MobInit requires Table, BuffSystem, Patrol, NefUnion, WarlockGlobal, StunUtils {
constant integer MOBINIT_RESPAWN_L = 510;
constant integer MOBINIT_RESPAWN_H = 600;

    private HandleTable idTable;
    private integer numMobs;

    function cancelForm(DelayTask dt) {
        IssueImmediateOrderById(dt.u0, OID_UNBEARFORM);
    }
    
    function cancelStun(DelayTask dt) {
        RemoveStun(dt.u0);
    }	

    public function ResetMob(unit u) {
        integer id = idTable[u];
        BuffSlot[u].removeAllBuff();   
        if (UnitProp[u].Stunned()) {
            // print("cancel stun");
            DelayTask.create(cancelStun, 0.5).u0 = u;
        }     

        if (GetUnitTypeId(u) == UTID_ARCH_TINKER_MORPH || GetUnitTypeId(u) == UTIDTIDEBARONWATER) {
            DelayTask.create(cancelForm, 1.0).u0 = u;
        }
		
		if (GetUnitTypeId(u) == UTIDWARLOCK) {
			ResetFireRunes();
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
    
    private function onInit() {
        numMobs = 0;
        idTable = HandleTable.create();

        // Mob respawn
        TimerStart(CreateTimer(), 5.0, true, function() {
            integer i;
            for (0 <= i < numMobs) {
                if (IsUnitDead(mobInfo[i].u)) {
                    if (mobInfo[i].respawning == -1) {
                        mobInfo[i].respawning = 1;
                        mobInfo[i].respawnCounter = GetRandomInt(mobInfo[i].respawnTime, mobInfo[i].respawnTimeVar);
                    } else {
                        mobInfo[i].respawnCounter -= 5;
                        if (mobInfo[i].respawnCounter <= 0) {
                            mobInfo[i].respawning = -1;
                            mobInfo[i].u = CreateUnit(Player(MOB_PID), mobInfo[i].utid, mobInfo[i].x, mobInfo[i].y, mobInfo[i].f);
                            mobInfo[i].p.update(mobInfo[i].u);
                            idTable[mobInfo[i].u] = i;
                        }
                    }
                }
            }
        });

        // Mob init
        TimerStart(CreateTimer(), 0.15, false, function() {
            group g;
            unit tu, u;
            Patroller p;
            DestroyTimer(GetExpiredTimer());

            g = NewGroup();
            GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
            tu = FirstOfGroup(g);
            while (tu != null) {
                if (GetPidofu(tu) == 6) {
                    RemoveUnit(tu);
                    u = CreateUnit(Player(10), GetUnitTypeId(tu), GetUnitX(tu), GetUnitY(tu), GetUnitFacing(tu));
                    mobInfo[numMobs].x = GetUnitX(tu); 
                    mobInfo[numMobs].y = GetUnitY(tu); 
                    mobInfo[numMobs].f = GetUnitFacing(tu); 
                    mobInfo[numMobs].utid = GetUnitTypeId(tu);
                    mobInfo[numMobs].u = u;
                    mobInfo[numMobs].respawnCounter = 0;
                    mobInfo[numMobs].respawning = -1;
                    mobInfo[numMobs].respawnTime = MOBINIT_RESPAWN_L;
                    mobInfo[numMobs].respawnTimeVar = MOBINIT_RESPAWN_H;
                    mobInfo[numMobs].p = 0;
                    idTable[u] = numMobs;
                    numMobs = numMobs + 1;
                }
                GroupRemoveUnit(g, tu);
                tu = FirstOfGroup(g);
            }
            ReleaseGroup(g);
            g = null;
            tu = null;

            // ********************* boss ************************
            // ("Ntin", "-8022.00", "-11433", "134")
            // ("Hvsh", "-6593.5", "-5616.7", "0.0")
            // ("Udea", "5819.00", "-4582.0", "90.0")
            // ("Ulic", "4608.00", "768.0", "270.0")
            // ("Ucrl", "5133.00", "8502.0", "0.0")
            // ("Nplh", "-5511.00", "579.0", "90.0")
            // ("Oshd", "573.00", "4800.0", "270.0")
            // ("Opgh", "741.00", "8989.0", "270.0")

            u = null;
        });
    }


}
//! endzinc
