//! zinc
library DarkRangerGlobal requires Table, ZAMCore {
    public unit ghoul[NUMBER_OF_MAX_PLAYERS];
    public unit darkranger[NUMBER_OF_MAX_PLAYERS];
    
    function grantGhoul(unit u) {
        real ang;
        if (GetUnitTypeId(u) == UTIDDARKRANGER) {
            ang = GetUnitFacing(u);
            ghoul[GetPlayerId(GetOwningPlayer(u))] = CreateUnit(GetOwningPlayer(u), UTIDGHOUL, GetUnitX(u) + 200 * CosBJ(ang + 90.0), GetUnitY(u) + 200 * SinBJ(ang + 90.0), ang);
            darkranger[GetPlayerId(GetOwningPlayer(u))] = u;
        }
    }
    
    public function DarkRangerHasGhoul(unit u) -> boolean {
        integer pid = GetPidofu(u);
        if (ghoul[pid] == null) {
            return false;
        } else {
            if (IsUnitDead(ghoul[pid])) {
                return false;
            } else {
                return true;
            }
        }
    }
    
    public function DarkRangerGetGhoul(unit u) -> unit {
        return ghoul[GetPidofu(u)];
    }
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            ghoul[i] = null;
            darkranger[i] = null;
            i += 1;
        }
        RegisterUnitEnterMap(grantGhoul);
    }
}
//! endzinc
