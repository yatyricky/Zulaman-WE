//! zinc
library PaladinGlobal {
    public constant integer LEVEL_TO_IMPROVE_FLASH_LIGHT = 3;
    
    public constant real healCrit[NUMBER_OF_MAX_PLAYERS];
    
    public function GetFlashLightAID(unit u) -> integer {
        integer fleshLight = SID_FLASH_LIGHT;
        if (GetUnitAbilityLevel(u, SID_DIVINE_FAVOR) == LEVEL_TO_IMPROVE_FLASH_LIGHT) {
            fleshLight = SID_FLASH_LIGHT_1;
        }
        return fleshLight;
    }
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            healCrit[i] = 0.0;
            i += 1;
        }
    }
}
//! endzinc
