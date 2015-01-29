//! zinc
library Regeneration requires UnitProperty, PlayerUnitList, AggroSystem {
#define INTERVAL 0.33
    //unit playerUnits[];
    //integer playerUnitsIndex;
    //unit[] mobs;
    //integer mn;
    
    public boolean regenlock = true;
    
    function regenAll() {
        integer i = 0;
        real r;
        boolean b = IsInCombat();
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i])) {
                r = UnitProp[PlayerUnits.units[i]].LifeRegen() * INTERVAL;
                if (!b && regenlock) {
                    r += GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.15 * INTERVAL;
                }
                if (GetWidgetLife(PlayerUnits.units[i]) + r > 1.0) {
                    SetWidgetLife(PlayerUnits.units[i], GetWidgetLife(PlayerUnits.units[i]) + r);
                } else {
                    SetWidgetLife(PlayerUnits.units[i], 1.0);
                }
                
                r = UnitProp[PlayerUnits.units[i]].ManaRegen() * INTERVAL;
                if (!b && regenlock) {
                    r += GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_MANA) * 0.15 * INTERVAL;
                }                
                ModUnitMana(PlayerUnits.units[i], r);
            }
            i += 1;
        }
        //i = 0;
        //while (i < mn) {
        //    if (!IsUnitDead(mobs[i])) {
        //        r = UnitProp.LifeRegen(playerUnits[i]);
        //        if (!b) {
        //            r += GetUnitState(playerUnits[i], UNIT_STATE_MAX_LIFE) * 0.15;
        //        }
        //        SetWidgetLife(playerUnits[i], GetWidgetLife(playerUnits[i]) + r);
        //        r = UnitProp.ManaRegen(playerUnits[i]);
        //        if (!b) {
        //            r += GetUnitState(playerUnits[i], UNIT_STATE_MAX_MANA) * 0.15;
        //        }
        //        SetUnitState(playerUnits[i], UNIT_STATE_MANA, GetUnitState(playerUnits[i], UNIT_STATE_MANA) + r);
        //    }
        //    i += 1;
        //}
    }
    
    //function register(unit u) {
    //    if (GetPlayerId(GetOwningPlayer(u)) < NUMBER_OF_MAX_PLAYERS) {
    //        playerUnits[playerUnitsIndex] = u;
    //        playerUnitsIndex += 1;
        //} else if (GetPlayerId(GetOwningPlayer(u)) == 10) {
        //    mobs[mn] = u;
        //    mn += 1;
    //    }
    //}

    function onInit() {
        //RegisterUnitEnterMap(register);
        TimerStart(CreateTimer(), INTERVAL, true, function regenAll);
        //playerUnitsIndex = 0;
        //mn = 0;        
    }
}
#undef INTERVAL
//! endzinc
