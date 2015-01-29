//! zinc
library BladeMasterGlobal requires ZAMCore, MultipleAbility {
#define PREMISE 'e00B'
    public constant integer BUFF_ID_REND = 'A008';
    public constant integer BUFF_ID_REND1 = 'A00J';   
    public constant integer BM_VALOUR_MAX = 17;
    public unit premises[NUMBER_OF_MAX_PLAYERS];
    
    public integer valour[NUMBER_OF_MAX_PLAYERS];
    
    public function EnableOverpower(integer id) {
        if (premises[id] != null) {
            if (IsUnitDead(premises[id])) {
                premises[id] = CreateUnit(Player(id), PREMISE, DUMMY_X, DUMMY_Y, 0);
            } else {
                SetWidgetLife(premises[id], 10);
            }
        } else {
            premises[id] = CreateUnit(Player(id), PREMISE, DUMMY_X, DUMMY_Y, 0);
        }
    }
    
    public function IncreaseValour(unit u, integer n) {
        player p = GetOwningPlayer(u);
        integer id = GetPlayerId(p);
        integer show, j;
        valour[id] += n;
        if (valour[id] > BM_VALOUR_MAX) {
            valour[id] = BM_VALOUR_MAX;
        }
        //BJDebugMsg("Valour + "+I2S(n)+" = " + I2S(valour[id]));
        show = (valour[id] + 3) / 4;
        j = SIDEXECUTESTART;
        while (j <= SIDEXECUTEEND) {
            SetPlayerAbilityAvailable(p, j, (j - SIDEXECUTESTART) == show);
            j += 1;
        }
        if (show == 5) {
            SystemOrderIndicator = true;
            IssueImmediateOrderById(u, 852458);
        }
    }
    
    public function GetAllVlour(unit u) -> integer {
        player p = GetOwningPlayer(u);
        integer i = GetPlayerId(p);
        integer ret = valour[i];
        valour[i] = 0;
        SetPlayerAbilityAvailable(p, SIDEXECUTESTART, true);
        i = SIDEXECUTESTART + 1;
        while (i <= SIDEXECUTEEND) {
            SetPlayerAbilityAvailable(p, i, false);
            i += 1;
        }
        return ret;
    }
    
    public function BladeMasterPeekValour(unit u) -> integer {
        return valour[GetPidofu(u)];
    }
    
    public function BladeMasterCanOverpower(unit u) -> boolean {
        integer id = GetPidofu(u);
        if (premises[id] != null) {
            if (IsUnitDead(premises[id])) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            premises[i] = null;
            valour[i] = 0;
            i += 1;
        }   
    }
}
#undef PREMISE
//! endzinc
