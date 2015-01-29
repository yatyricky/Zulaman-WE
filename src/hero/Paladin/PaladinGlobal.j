//! zinc
library PaladinGlobal {
    public constant string ART_FLASH_OF_LIGHT = "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl";
    public constant string ART_HOLY_LIGHT = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl";
    public constant integer BUFF_ID_HOLY_LIGHT = 'A024';
    public constant integer LEVEL_TO_IMPROVE_FLASH_LIGHT = 3;
    
    public constant real healCrit[NUMBER_OF_MAX_PLAYERS];
    
    public HandleTable instantHolyBoltTab;
    
    public function IsPaladinInstant(unit u) -> boolean {
        return instantHolyBoltTab.exists(u);
    }
    
    public function GetFlashLightAID(unit u) -> integer {
        integer fleshLight = SIDFLASHLIGHT;
        if (GetUnitAbilityLevel(u, SIDDIVINEFAVOR) == LEVEL_TO_IMPROVE_FLASH_LIGHT) {
            fleshLight = SIDFLASHLIGHT1;
        }
        return fleshLight;
    }
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            healCrit[i] = 0.0;
            i += 1;
        }
        instantHolyBoltTab = HandleTable.create();
    }
}
//! endzinc
