//! zinc
library HeroSelection requires NefUnion, Table, ZAMCore, Loot, AllianceAIAction {

    force playerForce, aiForce;
    integer tank, heal, dps;
    IntegerPool tankpool, healpool, dpspool;
    Table classSpecRefTab, actualRef;
    boolean alreadySelected[];

    struct DoubleClick[] {
        timer tm;
        integer prev;
        boolean running;

        method click(integer id) {
            TimerStart(this.tm, 0.5, false, function() {
                thistype this = GetTimerData(GetExpiredTimer());
                PauseTimer(this.tm);
                this.reset();
            });
            this.prev = id;
            this.running = true;
        }

        method reset() {
            this.prev = 0;
            this.running = false;
        }

        method init() {
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.reset();
        }
    }
    
    function aiforcecb() {
        player p = GetEnumPlayer();
        integer utid;
        unit aipu;
        if (tank == 0) {
            utid = tankpool.get();
            tankpool.remove(utid);
            tank += 1;
        } else if (heal < 2) {
            utid = healpool.get();
            healpool.remove(utid);
            heal += 1;
        } else {
            utid = dpspool.get();
            dpspool.remove(utid);
            dps += 1;
        }
        aipu = CreateUnit(p, utid, GetInitX(GetPlayerId(p)), GetInitY(GetPlayerId(p)), 270);
        GroupAddUnit(PlayerUnits.g, aipu);
        classSpec.add(classSpecRefTab[utid], 10);
        RegisterAIAlliance(aipu);
        SetPlayerAlliance(p, Player(0), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(p, Player(1), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(p, Player(2), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(p, Player(3), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(p, Player(4), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(p, Player(5), ALLIANCE_SHARED_CONTROL, true);
        p = null;
        aipu = null;
    }

    function heroSelected() -> boolean {
        player p = GetTriggerPlayer();
        integer pid = GetPlayerId(p);
        integer i;
        unit u;
        unit selectUnit = GetTriggerUnit();
        integer utid;
        integer selUTID = GetUnitTypeId(selectUnit);
        if (actualRef.exists(selUTID) == false) {p = null; u = null; selectUnit = null; return false;}
        if (alreadySelected[pid] == true) {p = null; u = null; selectUnit = null; return false;}

        if (DoubleClick[pid].prev == selUTID && DoubleClick[pid].running == true) {
            utid = actualRef[GetUnitTypeId(selectUnit)];

            alreadySelected[pid] = true;
            u = CreateUnit(p, utid, GetUnitX(selectUnit) - 64, GetUnitY(selectUnit) - 64, 270);
            SelectUnitForPlayerSingle(u, p);
            GroupAddUnit(PlayerUnits.g, u);
            classSpec.add(classSpecRefTab[utid], 10);

            if (utid == UTID_BLOOD_ELF_DEFENDER || utid == UTID_CLAW_DRUID) {
                tank += 1;
                tankpool.remove(utid);
            }
            if (utid == UTID_PALADIN || utid == UTID_PRIEST || utid == UTID_KEEPER_OF_GROVE) {
                heal += 1;
                healpool.remove(utid);
            }
            if (utid == UTID_BLADE_MASTER || utid == UTID_ROGUE || utid == UTID_DARK_RANGER || utid == UTID_FROST_MAGE || utid == UTID_EARTH_BINDER || utid == UTID_HEATHEN) {
                dps += 1;
                dpspool.remove(utid);
            }
            
            ForceRemovePlayer(playerForce, p);
            // done with hero selection
            if (CountPlayersInForceBJ(playerForce) == 0) {
                ForForce(aiForce, function aiforcecb);
                tankpool.destroy();
                healpool.destroy();
                dpspool.destroy();
            }
            p = null;
            u = null;
            selectUnit = null;
        } else {
            DoubleClick[pid].click(selUTID);
        }

        return false;
    }
    
    function grantSkillPoints(unit u) {
        if (IsUnitType(u, UNIT_TYPE_HERO)) {
            if (GetPlayerId(GetOwningPlayer(u)) < NUMBER_OF_MAX_PLAYERS) {
                UnitModifySkillPoints(u, 2);
            }
        }
    }

    function onInit() {
        integer i = 0;
        player p;
        playerForce = CreateForce();
        aiForce = CreateForce();
        while (i < NUMBER_OF_MAX_PLAYERS) {
            alreadySelected[i] = false;
            p = Player(i);
            if (IsPlayerUserOnline(p)) {
                ForceAddPlayer(playerForce, p);
                DoubleClick[GetPlayerId(p)].init();
            } else {
                ForceAddPlayer(aiForce, p);
            }
            i += 1;
        }
        
        tank = 0;
        heal = 0;
        dps = 0;
        tankpool = IntegerPool.create();
        healpool = IntegerPool.create();
        dpspool = IntegerPool.create();
        tankpool.add(UTID_BLOOD_ELF_DEFENDER, 10);
        tankpool.add(UTID_CLAW_DRUID, 10);
        healpool.add(UTID_PRIEST, 10);
        healpool.add(UTID_PALADIN, 10);
        healpool.add(UTID_KEEPER_OF_GROVE, 10);
        dpspool.add(UTID_FROST_MAGE, 10);
        dpspool.add(UTID_EARTH_BINDER, 10);
        dpspool.add(UTID_HEATHEN, 10);
        dpspool.add(UTID_BLADE_MASTER, 10);
        dpspool.add(UTID_DARK_RANGER, 10);
        dpspool.add(UTID_ROGUE, 10);

        TriggerAnyUnit(EVENT_PLAYER_UNIT_SELECTED, function heroSelected);
        RegisterUnitEnterMap(grantSkillPoints);

        // class spec item reference table
        classSpecRefTab = Table.create();
        classSpecRefTab[UTID_BLOOD_ELF_DEFENDER] = ITID_ORB_OF_THE_SINDOREI;
        classSpecRefTab[UTID_CLAW_DRUID] = ITID_REFORGED_BADGE_OF_TENACITY;
        classSpecRefTab[UTID_PALADIN] = ITID_LIGHTS_JUSTICE;
        classSpecRefTab[UTID_PRIEST] = ITID_BENEDICTION;
        classSpecRefTab[UTID_KEEPER_OF_GROVE] = ITID_HORN_OF_CENARIUS;
        classSpecRefTab[UTID_BLADE_MASTER] = ITID_BANNER_OF_THE_HORDE;
        classSpecRefTab[UTID_ROGUE] = ITID_KELENS_DAGGER_OF_ASSASSINATION;
        classSpecRefTab[UTID_DARK_RANGER] = ITID_RHOKDELAR;
        classSpecRefTab[UTID_FROST_MAGE] = ITID_RAGE_WINTERCHILLS_PHYLACTERY;
        classSpecRefTab[UTID_HEATHEN] = ITID_ANATHEMA;
        classSpecRefTab[UTID_EARTH_BINDER] = ITID_RARE_SHIMMER_WEED;

        actualRef = Table.create();
        actualRef['H008'] = UTID_BLOOD_ELF_DEFENDER;
        actualRef['H00A'] = UTID_CLAW_DRUID;
        actualRef['H00D'] = UTID_PALADIN;
        actualRef['O001'] = UTID_PRIEST;
        actualRef['E00O'] = UTID_KEEPER_OF_GROVE;
        actualRef['O000'] = UTID_BLADE_MASTER;
        actualRef['E00N'] = UTID_ROGUE;
        actualRef['N013'] = UTID_DARK_RANGER;
        actualRef['H00C'] = UTID_FROST_MAGE;
        actualRef['H009'] = UTID_HEATHEN;
        actualRef['H00B'] = UTID_EARTH_BINDER;
        
        p = null;
    }


}
//! endzinc
