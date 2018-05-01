//! zinc
library GrantAbilityPoints requires NefUnion, ZAMCore {

    function bossDown(unit u) {
        integer utid = GetUnitTypeId(u);
        integer i;
        if (utid == UTID_ARCH_TINKER || utid == UTID_ARCH_TINKER_MORPH || /*
                */ utid == UTID_NAGA_SEA_WITCH || /*
                */ utid == UTID_TIDE_BARON || utid == UTID_TIDE_BARON_WATER || /*
                */ utid == UTID_WARLOCK) {
            CURRENT_HERO_LEVEL += 1;
        }
    }

    //string foo[];

    function onInit() {
        RegisterUnitDeath(bossDown);
        
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function() -> boolean {
            UnitModifySkillPoints(GetTriggerUnit(), 2);
            return false;
        });
        //foo[0] = "fuck";
    }
}
//! endzinc
