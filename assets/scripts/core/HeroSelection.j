//! zinc
library HeroSelection requires NefUnion, Table, ZAMCore, Loot, AllianceAIAction {
constant integer HERO_SLCT_LOW = 'IHS0';
constant integer HERO_SLCT_HIGH = 'IHS;';

    Table heroRefTab;
    force playerForce, pf, aiForce;
    integer tank, heal, dps;
    IntegerPool tankpool, healpool, dpspool;
    Table classSpecRefTab;
    
    function aiforcecb() {
        player p = GetEnumPlayer();
        integer id;
        unit aipu;
        if (tank == 0) {
            id = tankpool.get();
            tankpool.remove(id);
            tank += 1;
        } else if (heal < 2) {
            id = healpool.get();
            healpool.remove(id);
            heal += 1;
        } else {
            id = dpspool.get();
            dpspool.remove(id);
            dps += 1;
        }
        aipu = CreateUnit(p, heroRefTab[id], GetInitX(GetPlayerId(p)), GetInitY(GetPlayerId(p)), 270);
        GroupAddUnit(PlayerUnits.g, aipu);
        classSpec.add(classSpecRefTab[heroRefTab[id]], 10);
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
        integer aid = GetItemTypeId(GetManipulatedItem());
        unit u;
        player p = GetOwningPlayer(GetTriggerUnit());
        integer i;
        if (aid >= HERO_SLCT_LOW && aid <= HERO_SLCT_HIGH) {
            u = CreateUnit(p, heroRefTab[aid], GetInitX(GetPlayerId(p)), GetInitY(GetPlayerId(p)), 270);
            PanCameraToTimedForPlayer(p, GetInitX(GetPlayerId(p)), GetInitY(GetPlayerId(p)), 1.00);
            SelectUnitForPlayerSingle(u, p);
            GroupAddUnit(PlayerUnits.g, u);
            classSpec.add(classSpecRefTab[heroRefTab[aid]], 10);
            RemoveItem(GetManipulatedItem());
            KillUnit(GetTriggerUnit());
            
            if (aid == 'IHS0' || aid == 'IHS1') {
                tank += 1;
                tankpool.remove(aid);
            }
            if (aid == 'IHS2' || aid == 'IHS3' || aid == 'IHS4') {
                heal += 1;
                healpool.remove(aid);
            }
            if (aid >= 'IHS5' && aid <= 'IHS:') {
                dps += 1;
                dpspool.remove(aid);
            }
            
            ForceRemovePlayer(pf, p);
            // done with hero selection
            if (CountPlayersInForceBJ(pf) == 0) {
                ForForce(aiForce, function aiforcecb);
                tankpool.destroy();
                healpool.destroy();
                dpspool.destroy();
                
            }
        }
        p = null;
        u = null;
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
        pf = CreateForce();
        aiForce = CreateForce();
        while (i < NUMBER_OF_MAX_PLAYERS) {
            p = Player(i);
            // CreateUnit(p, 'e001', GetInitX(i), GetInitY(i), 0.0);
            if (IsPlayerUserOnline(p)) {
                ForceAddPlayer(playerForce, p);
                ForceAddPlayer(pf, p);
                CreateUnit(p, 'ncop', -6784 - 128 * i, -1856, 0.0);
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
        tankpool.add('IHS0', 10);
        tankpool.add('IHS1', 10);
        healpool.add('IHS2', 10);
        healpool.add('IHS3', 10);
        healpool.add('IHS4', 10);
        dpspool.add('IHS5', 10);
        dpspool.add('IHS6', 10);
        dpspool.add('IHS7', 10);
        dpspool.add('IHS8', 10);
        dpspool.add('IHS9', 10);
        dpspool.add('IHS:', 10);
        
        RegisterUnitEnterMap(grantSkillPoints);
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function heroSelected);
        heroRefTab = Table.create();
        heroRefTab['IHS0'] = 'Hmkg';
        heroRefTab['IHS1'] = 'Hlgr';
        heroRefTab['IHS2'] = 'Emfr';
        heroRefTab['IHS3'] = 'Hart';
        heroRefTab['IHS4'] = 'Ofar';
        heroRefTab['IHS5'] = 'Obla';
        heroRefTab['IHS6'] = 'Nbrn';
        heroRefTab['IHS7'] = 'Hjai';
        heroRefTab['IHS8'] = 'Hapm';
        heroRefTab['IHS9'] = 'Edem';
        heroRefTab['IHS:'] = 'Hblm';
        
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
        
        p = null;
        
        //SetPlayerAlliance(Player(9), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(8), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(7), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(6), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(5), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(4), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(3), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(2), Player(0), ALLIANCE_SHARED_CONTROL, true);
        //SetPlayerAlliance(Player(1), Player(0), ALLIANCE_SHARED_CONTROL, true);
    }


}
//! endzinc
