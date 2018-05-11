//! zinc
library Command requires Console, StunUtils, UnitProperty, BuffSystem, DamageSystem, IntegerPool, Regeneration, WarlockGlobal, LightningShield, PlayerUnitList, ItemAttributes {
    
    function testStunUnit(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        //BJDebugMsg("wocao " + GetUnitName(u) + " " + SubString(str, 5, StringLength(str)));
        StunUnit(u, u, S2R(SubString(str, 5, StringLength(str))));
        //BJDebugMsg("wocao");
        DestroyGroup(g);
    }
    
    function countAllUnitsInMap(string str) {
        group g = CreateGroup();
        GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
        BJDebugMsg(I2S(CountUnitsInGroup(g)));
        DestroyGroup(g);
    }
    
    function levelUp(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        DestroyGroup(g);
    }
    
    function addAbility(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        UnitAddAbility(u, S2ID(SubString(str, 4, 8)));
        DestroyGroup(g);
    }
    
    function resetAbility(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        UnitRemoveAbility(u, S2ID(SubString(str, 3, 7)));
        UnitAddAbility(u, S2ID(SubString(str, 3, 7)));
        DestroyGroup(g);
    }
    
    function abillvl(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        BJDebugMsg(I2S(GetUnitAbilityLevel(u, S2ID(SubString(str, 5, 9)))));
        DestroyGroup(g);
    }
    
    function removeAbility(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        UnitRemoveAbility(u, S2ID(SubString(str, 4, 8)));
        DestroyGroup(g);
    }
    
    function modUnitAttackPower(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        ModUnitAP(u, S2I(SubString(str, 4, StringLength(str))));
        DestroyGroup(g);
    }
    
    function printBuffList(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        BuffSlot[u].print();
        DestroyGroup(g);
    }
    
    function createunit(string str) {
        integer pid = S2I(SubString(str, 5, 7));
        CreateUnit(Player(pid), S2ID(SubString(str, 8, 12)), GetInitX(pid), GetInitY(pid), 270.0);
    }
    
    function createitem(string str) {
        CreateItemEx(S2ID(SubString(str, 5, 9)), GetInitX(0), GetInitY(0), GetRandomReal(10000, 100000));
    }
    
    function screenClear(string str) {
    
        //SetTerrainType(6144, 6656, 'Wsnw', -1, 5, 0);
        ClearTextMessages();
    }
    /*
    function showcoord(string str) {
        unit u; 
        group g = CreateGroup();
        vector v;
        location loc;
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        
        loc = Location(GetUnitX(u), GetUnitY(u));
        v = vector.create(GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u) + GetLocationZ(loc));
        BJDebugMsg("x: " + R2S(v.x) + ", y: " + R2S(v.y) + ", z: " + R2S(v.z));
        RemoveLocation(loc);
        
        DestroyGroup(g);
    }*/
    
    function seeOID(string str) {
        BJDebugMsg(I2S(OrderId(SubString(str, 4, StringLength(str)))));
    }
    
    function lifelocker(string str) {
        lifelock = !lifelock;
    }
    
    function regenlocker(string str) {
        regenlock = !regenlock;
    }
    
    function playanimation(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        SetUnitAnimation(u, SubString(str, 6, StringLength(str)));
        DestroyGroup(g);
    }
    
    function colourMix(string str) {
        BJDebugMsg("|cffffff00RG|r");
        BJDebugMsg("|cff00ffffGB|r");
        BJDebugMsg("|cffff00ffRB|r");
    }
    
    function dispelall(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        BuffSlot[u].removeAllBuff();
        DestroyGroup(g);
    }
    
    function die(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        KillUnit(u);
        DestroyGroup(g);
    }
    
    function gethandleidunit(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        BJDebugMsg(I2HEX(GetHandleId(u)));
        DestroyGroup(g);
    }
    
    function getutid(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        BJDebugMsg(ID2S(GetUnitTypeId(u)));
        DestroyGroup(g);
    }
    
    function testpool(string str) {
        IntegerPool ip = IntegerPool.create();
        integer i, j, k, l, n;
        ip.add(5, 10);
        ip.add(6, 10);
        ip.add(7, 20);
        ip.add(5, 33);
        ip.add(6, 33);
        ip.add(7, 33);
        ip.remove(5);
        ip.remove(6);
        ip.remove(7);
        i = 0;
        j = 0;
        l = 0;
        k = 0;
        while (i < 50) {
            n = ip.get();
            if (n == 5) {
                j += 1;
            } else if (n == 6) {
                k += 1;
            } else if (n == 7) {
                l += 1;
            } else {
                BJDebugMsg("Error: " + I2S(n));
            }
            i += 1;
        }
        BJDebugMsg("5: " + I2S(j) + ", 6: " + I2S(k) + ", 7: " + I2S(l));
    }
    
    function getseefrs(string str) {    
        CameraSetupApplyForceDuration(gg_cam_LookWarlockPlatform, true, 0);
    }
    
    function spawnpotions(string str) {
        real x = GetCameraTargetPositionX();
        real y = GetCameraTargetPositionY();

    }
    
    function execfuncs(string str) {
        ExecuteFunc(SubString(str, 5, StringLength(str)));
    }
    
    function doresetlavas(string str) {
        ResetFireRunes();
    }
    
    function generatecombatlogs(string str) {
        GenerateCombatLog(SubString(str, 4, StringLength(str)));
    }
    
    function debuglogs(string str) {
        ExportDebugLog();
    }
    
    function testprayerofhealing(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        IssueNeutralPointOrderById(GetOwningPlayer(u), u, OrderId("blizzard"), GetUnitX(u), GetUnitY(u));
        DestroyGroup(g);
    }
    
    //lightning testlightning;
    
    function chooselightiningcolour(string str) {
        real r = S2R(SubString(str, 4, 7));
        real g = S2R(SubString(str, 8, 11));
        real b = S2R(SubString(str, 12, 15));
        //SetLightningColor(testlightning, r, g, b, 1.0);
    }
    
    function poyicengdun(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        LightningShield.shatter(u);
        DestroyGroup(g);
    }
    
    function testifunitcanuse(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        
        print(B2S(UnitCanUse(u, S2ID(SubString(str, 7, 11)))));
        
        DestroyGroup(g);
    }
    
    function testwarlock(string str) {
        real testx = 7221;
        real testy = 9027;
        integer i = 0;
        while (i < PlayerUnits.n) {
            SetUnitPosition(PlayerUnits.units[i], testx, testy);
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 10000));
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 30000));
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 50000));
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 70000));
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 90000));
            UnitAddItem(PlayerUnits.units[i], CreateItemEx('Ieng', testx, testy, 110000));
            i += 1;
        }
    }

    function testPrintFireBomb(string str) {
        //printMarkMap();
    }

    function testgetangle(string str) {
        print(R2S(GetAngleDeg(1,1,2,0.75)));
        print(R2S(GetAngleDeg(1,1,0,0.5)));
        print(R2S(AcosBJ(0.7)));
    }

    function testGeneral(string str) {
        real x = 8624;
        real y = -5439;
        unit u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        u = CreateUnit(Player(0), UTID_CLAW_DRUID, x, y, 0);
        SetHeroLevel(u, GetHeroLevel(u) + 14, true);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 10000);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 30000);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 50000);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 70000);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 90000);
        CreateItemEx(ITID_BREATH_OF_THE_DYING, x, y, 110000);
        MobInitAllowArea(4);
    }

    function testItemAttributes(string str) {
        real rnd = GetRandomReal(150000, 220000);
        print("drop value = "+ R2S(rnd));
        CreateItemEx(ITID_BREATH_OF_THE_DYING, INIT_X, INIT_Y, rnd);
    }

    function getunitlevel(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        
        print(I2S(GetUnitLevel(u)));
        
        DestroyGroup(g);
    }

    function printStats(string str) {
        unit u; 
        group g = CreateGroup();
        GroupEnumUnitsSelected(g, Player(0), null);
        u = FirstOfGroup(g);
        
        print("==== "+GetUnitNameEx(u)+" ====");
        print("-- Physics --");
        print("AP: "+I2S(UnitProp.inst(u, SCOPE_PREFIX).APMin()) + " - " + I2S(UnitProp.inst(u, SCOPE_PREFIX).APMax())+" CRIT: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).AttackCrit() * 100) + "%"+" IAS: "+I2S(UnitProp.inst(u, SCOPE_PREFIX).AttackSpeed() + 100) + "%"+" AR: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).AttackRate() * 100) + "%");
        print("-- Magic --");
        print("SP: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).SpellPower())+" SC: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).SpellCrit() * 100) + "%"+" SH: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).SpellHaste() * 100) + "%");
        print("-- Defense --");
        print("AM: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).Armor())+" DG: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).Dodge() * 100) + "%"+" BR: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).BlockRate() * 100) + "%("+R2S(UnitProp.inst(u, SCOPE_PREFIX).BlockPoint())+")");
        print("MDEF: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).SpellTaken() * 100) + "%"+" DT: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).DamageTaken() * 100) + "%"+" HT: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).HealTaken() * 100) + "%");
        print("-- Miscs --");
        print("Refl: "+I2S(UnitProp.inst(u, SCOPE_PREFIX).SpellReflect())+" Aggro: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).AggroRate() * 100) + "%"+" Disabled: "+B2S(UnitProp.inst(u, SCOPE_PREFIX).Disabled()));
        print("Regen: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).LifeRegen())+"/"+R2S(UnitProp.inst(u, SCOPE_PREFIX).ManaRegen())+" Speed: "+I2S(UnitProp.inst(u, SCOPE_PREFIX).Speed())+" Amp: "+R2S(UnitProp.inst(u, SCOPE_PREFIX).DamageDealt() * 100) + "%");
        
        DestroyGroup(g);
    }

    private function onInit() {
        //Console[Player(0)].add("stun", testStunUnit);
        Console[Player(0)].add("cls", screenClear);
        //Console[Player(0)].add("countunits", countAllUnitsInMap);
        Console[Player(0)].add("lvlup", levelUp);
        Console[Player(0)].add("lvl", getunitlevel);
        //Console[Player(0)].add("oid", seeOID);
        Console[Player(0)].add("add", addAbility);
        //Console[Player(0)].add("ra", resetAbility);
        //Console[Player(0)].add("alvl", abillvl);
        //Console[Player(0)].add("rem", removeAbility);
        //Console[Player(0)].add("atk", modUnitAttackPower);
        //Console[Player(0)].add("get", getUnitAtt);
        // Console[Player(0)].add("bl", printBuffList);
        Console[Player(0)].add("unit", createunit);
        Console[Player(0)].add("item", createitem);
        // Console[Player(0)].add("anime", playanimation);
        // Console[Player(0)].add("lifelock", lifelocker);
        // Console[Player(0)].add("regenlock", regenlocker);
        // Console[Player(0)].add("colourmix", colourMix);
        // Console[Player(0)].add("dispelall", dispelall);
        // Console[Player(0)].add("testpool", testpool);
        Console[Player(0)].add("die", die);
        //Console[Player(0)].add("hid", gethandleidunit);
        Console[Player(0)].add("utid", getutid);
        //Console[Player(0)].add("seefrs", getseefrs);
        // Console[Player(0)].add("potions", spawnpotions);
        Console[Player(0)].add("exec", execfuncs);
        // Console[Player(0)].add("resetlava", doresetlavas);
        Console[Player(0)].add("log", generatecombatlogs);
        Console[Player(0)].add("dlog", debuglogs);
        // Console[Player(0)].add("prayerofhealing", testprayerofhealing);
        //testlightning = AddLightningEx("SPLK", false, -6786, -1867, 1710, -6342, -1923, 1710);
        // Console[Player(0)].add("ltn", testwarlock);
        // Console[Player(0)].add("podun", poyicengdun);
        // Console[Player(0)].add("canuse", testifunitcanuse);
        // Console[Player(0)].add("pfb", testPrintFireBomb);
        // console[Player(0)].add("testwlk", testwarlock);
        // Console[Player(0)].add("angle", testgetangle);
        Console[Player(0)].add("test", testGeneral);
        Console[Player(0)].add("zxc", testItemAttributes);
        Console[Player(0)].add("sta", printStats);
    }
}
//! endzinc
