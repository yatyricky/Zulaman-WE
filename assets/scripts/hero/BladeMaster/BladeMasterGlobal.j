//! zinc
library BladeMasterGlobal requires ZAMCore {
    constant integer PREMISE = 'e00B';
    public constant integer BUFF_ID_REND = 'A008';
    public constant integer BUFF_ID_REND1 = 'A00J';   
    
    public unit premises[NUMBER_OF_MAX_PLAYERS];
    
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
            i += 1;
        }
    }
}
//! endzinc
