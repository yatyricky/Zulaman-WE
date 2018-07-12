//! zinc
library ZAMCore requires NefUnion {
//==============================================================================
//  constant    string:     HEAL_EFF
//  constant    integer:    STOP_ID
//              region:     MAP_AREA
//==============================================================================
//              boolean:    IsUnitDummy(unit u)
//              boolean:    IsUnitDead(unit u)
//              boolean:    IsUnitStealth(unit u)
//              boolean:    DummyFilter()
//==============================================================================
// Dummy          : 2
// Able to block  : 3
// Able to attack : 5
// Summoned       : 7
// Ignore         : 11
//==============================================================================
    public region MAP_AREA;
    public integer CURRENT_HERO_LEVEL;
    public unit PlayerSelection[NUMBER_OF_MAX_PLAYERS];
    private trigger playerSelectionTrigger;
    
    // true if unit1 > unit2
    public type UnitListSortRule extends function(unit, unit) -> boolean;

    public function IsUnitDummy(unit u) -> boolean {
        //return (GetUnitPointValue(u) < 32);
        return (ModuloInteger(GetUnitPointValue(u), 2) == 0);
    }

    public function IsUnitChampion(unit u) -> boolean {
        return (GetUnitLevel(u) == 4);
    }
    
    public function CanUnitBlock(unit u) -> boolean {
        return (ModuloInteger(GetUnitPointValue(u), 3) == 0);
    }
    
    public function CanUnitAttack(unit u) -> boolean {
        //return (GetUnitPointValue(u) < 1000);
        return (ModuloInteger(GetUnitPointValue(u), 5) == 0);
    }
    
    public function IsUnitSummoned(unit u) -> boolean {
        //return (GetUnitPointValue(u) == 255 || GetUnitPointValue(u) == 256);
        return (ModuloInteger(GetUnitPointValue(u), 7) == 0);
    }
    
    public function IsUnitUseless(unit u) -> boolean {
        //return (GetUnitPointValue(u) == 256);
        return (ModuloInteger(GetUnitPointValue(u), 11) == 0);
    }
    
    public function IsUnitBoss(unit u) -> boolean {
        return (IsUnitType(u, UNIT_TYPE_HERO) && GetPlayerId(GetOwningPlayer(u)) == MOB_PID);
    }

    public function IsUnitDead(unit u) -> boolean {
        return GetWidgetLife(u) < 0.405 || IsUnitType(u, UNIT_TYPE_DEAD);
    }

    public function IsUnitStealth(unit u) -> boolean {
        return (GetUnitAbilityLevel(u, SID_APIV) > 0);
    }
    
    public function IsUnitTank(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == UTID_BLOOD_ELF_DEFENDER || id == UTID_CLAW_DRUID);
    }

    public function IsUnitDPS(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == UTID_DARK_RANGER || id == UTID_BLADE_MASTER || id == UTID_FROST_MAGE || id == UTID_EARTH_BINDER || id == UTID_EARTH_BINDER_ASC || id == UTID_ROGUE || id == UTID_HEATHEN);
    }
    
    public function IsUnitMelee(unit u) -> boolean {
        integer id = GetUnitTypeId(u);
        return (id == UTID_BLOOD_ELF_DEFENDER || id == UTID_CLAW_DRUID || id == UTID_BLADE_MASTER || id == UTID_ROGUE);
    }
    
    public function DummyFilter() -> boolean {
        return (ModuloInteger(GetUnitPointValue(GetFilterUnit()), 2) != 0);
    }
    
    public function DummyDeadFilter() -> boolean {
        return (ModuloInteger(GetUnitPointValue(GetFilterUnit()), 2) != 0) && !IsUnitDead(GetFilterUnit());
    }
    
    public type UnitEventResponse extends function(unit);
    private UnitEventResponse uemrs[];
    private integer uemrsn = 0;
    public function RegisterUnitEnterMap(UnitEventResponse r) {
        uemrs[uemrsn] = r;
        uemrsn += 1;
    }
    private UnitEventResponse udrs[];
    private integer udrsn = 0;
    public function RegisterUnitDeath(UnitEventResponse r) {
        udrs[udrsn] = r;
        udrsn += 1;
    }
    
    public function GetInitX(integer pid) -> real {
        return INIT_X + 192.0 * Cos(pid * bj_PI / 3.0);
    }
    
    public function GetInitY(integer pid) -> real {
        return INIT_Y + 192.0 * Sin(pid * bj_PI / 3.0);
    }
    
    public function MoveUnit(unit u, real x, real y) {
        real dis = GetDistance.unitCoord2d(u, x, y);
        real angle = GetAngle(GetUnitX(u), GetUnitY(u), x, y);
        integer steps = Rounding(dis / 20.0);
        real dx, dy;
        dis = dis / steps;
        dx = Cos(angle) * dis;
        dy = Sin(angle) * dis;
        x = GetUnitX(u);
        y = GetUnitY(u);
        while (steps > 0) {
            x += dx;
            y += dy;
            if (!IsTerrainWalkable(x, y)) {
                steps = 0;
            }
            steps -= 1;
        }
        SetUnitPosition(u, x, y);
    }
    
    public function SetUnitPositionEx(unit u, real x, real y) {
        integer i = 1;
        real theta, r;
        real newx = x;
        real newy = y;
        while (!IsTerrainWalkable(x, y)) {
            theta = 0.523598776 * i;
            r = 10 + 10 * theta;
            newx = x + Cos(theta) * r;
            newy = y + Sin(theta) * r;
            i += 1;
        }
        SetUnitPosition(u, newx, newy);
    }
    
    function onInit() {
        trigger regTrig = CreateTrigger();
        integer i;
        
        CURRENT_HERO_LEVEL = 1;
        
        SetPlayerName(Player(10), FORCE_ENEMY);
        SetPlayerName(Player(11), FORCE_NPCS);
        // FogEnable(false);
        // FogMaskEnable(false);
        SetPlayerAlliance(Player(10), Player(0), ALLIANCE_SHARED_CONTROL, true);
        
        SetPlayerAlliance(Player(11), Player(0), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(1), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(2), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(3), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(4), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(5), ALLIANCE_SHARED_CONTROL, true);
        SetPlayerAlliance(Player(11), Player(0), ALLIANCE_PASSIVE, true);
        SetPlayerAlliance(Player(11), Player(1), ALLIANCE_PASSIVE, true);
        SetPlayerAlliance(Player(11), Player(2), ALLIANCE_PASSIVE, true);
        SetPlayerAlliance(Player(11), Player(3), ALLIANCE_PASSIVE, true);
        SetPlayerAlliance(Player(11), Player(4), ALLIANCE_PASSIVE, true);
        SetPlayerAlliance(Player(11), Player(5), ALLIANCE_PASSIVE, true);
        
        MAP_AREA = CreateRegion();
        RegionAddRect(MAP_AREA, bj_mapInitialPlayableArea);
        TriggerRegisterEnterRegion(regTrig, MAP_AREA, Filter(function DummyFilter));
        TriggerAddCondition(regTrig, Condition(function() -> boolean {
            integer i = 0;
            while (i < uemrsn) {
                uemrs[i].evaluate(GetTriggerUnit());
                i += 1;
            }
            return false;
        }));
        
        regTrig = CreateTrigger();
        i = 0;
        while (i < bj_MAX_PLAYER_SLOTS) {
            TriggerRegisterPlayerUnitEvent(regTrig, Player(i), EVENT_PLAYER_UNIT_DEATH, Filter(function DummyFilter));
            i += 1;
        }
        TriggerAddCondition(regTrig, Condition(function() -> boolean {
            integer i = 0;
            if (!IsUnitDummy(GetTriggerUnit())) {
                while (i < udrsn) {
                    udrs[i].evaluate(GetTriggerUnit());
                    i += 1;
                }
            }
            return false;
        }));

        playerSelectionTrigger = CreateTrigger();
        TimerStart(CreateTimer(), 0.5, false, function() {
            integer i;
            DestroyTimer(GetExpiredTimer());
            for (0 <= i < NUMBER_OF_MAX_PLAYERS) {
                if (IsPlayerUserOnline(Player(i))) {
                    TriggerRegisterPlayerUnitEvent(playerSelectionTrigger, Player(i), EVENT_PLAYER_UNIT_SELECTED, null);
                }
            }
        });
        TriggerAddAction(playerSelectionTrigger, function() {
            unit u = GetTriggerUnit();
            if (u != null && !IsUnitDummy(u)) {
                PlayerSelection[GetPlayerId(GetTriggerPlayer())] = u;
            }
            u = null;
        });

    }
}
//! endzinc
