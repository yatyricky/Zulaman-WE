//! zinc
library Command requires Console, StunUtils, UnitProperty, BuffSystem, DamageSystem, IntegerPool, Regeneration, WarlockGlobal, LightningShield, PlayerUnitList {
    
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
        SetHeroLevel(u, GetHeroLevel(u) + 1, true);
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
        CreateItemEx(S2ID(SubString(str, 5, 9)), GetInitX(0), GetInitY(0));
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
		// PlayerUnits.units
		// PlayerUnits.n
		integer i = 0;
		while (i < PlayerUnits.n) {
			SetUnitPosition(PlayerUnits.units[i], 3930, -573);
			i += 1;
		}
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
		CreateItemEx('Ieng', 3930, -573);
	}

    function testPrintFireBomb(string str) {
        //printMarkMap();
    }

    function testgetangle(string str) {
        print(R2S(GetAngleDeg(1,1,2,0.75)));
        print(R2S(GetAngleDeg(1,1,0,0.5)));
        print(R2S(AcosBJ(0.7)));
    }
    
    private function onInit() {
        //Console[Player(0)].add("stun", testStunUnit);
        Console[Player(0)].add("cls", screenClear);
        //Console[Player(0)].add("countunits", countAllUnitsInMap);
        Console[Player(0)].add("lvlup", levelUp);
        //Console[Player(0)].add("oid", seeOID);
        //Console[Player(0)].add("add", addAbility);
        //Console[Player(0)].add("ra", resetAbility);
        //Console[Player(0)].add("alvl", abillvl);
        //Console[Player(0)].add("rem", removeAbility);
        //Console[Player(0)].add("atk", modUnitAttackPower);
        //Console[Player(0)].add("get", getUnitAtt);
        Console[Player(0)].add("bl", printBuffList);
        Console[Player(0)].add("unit", createunit);
        Console[Player(0)].add("item", createitem);
        Console[Player(0)].add("anime", playanimation);
        Console[Player(0)].add("lifelock", lifelocker);
        Console[Player(0)].add("regenlock", regenlocker);
        Console[Player(0)].add("colourmix", colourMix);
        Console[Player(0)].add("dispelall", dispelall);
        Console[Player(0)].add("testpool", testpool);
        Console[Player(0)].add("die", die);
        //Console[Player(0)].add("hid", gethandleidunit);
        //Console[Player(0)].add("utid", getutid);
        //Console[Player(0)].add("seefrs", getseefrs);
        Console[Player(0)].add("potions", spawnpotions);
        Console[Player(0)].add("exec", execfuncs);
        Console[Player(0)].add("resetlava", doresetlavas);
        Console[Player(0)].add("log", generatecombatlogs);
        Console[Player(0)].add("dlog", debuglogs);
        Console[Player(0)].add("prayerofhealing", testprayerofhealing);
        //testlightning = AddLightningEx("SPLK", false, -6786, -1867, 1710, -6342, -1923, 1710);
        Console[Player(0)].add("ltn", testwarlock);
        Console[Player(0)].add("podun", poyicengdun);
        Console[Player(0)].add("canuse", testifunitcanuse);
        Console[Player(0)].add("pfb", testPrintFireBomb);
		// console[Player(0)].add("testwlk", testwarlock);
        Console[Player(0)].add("angle", testgetangle);
    }
}
//! endzinc
