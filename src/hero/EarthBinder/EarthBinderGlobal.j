//! zinc
library EarthBinderGlobal requires NefUnion {
    //public constant integer BUFF_ID_STORM_STRIKE = 'A032';
    public integer currentTotemId[];
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            currentTotemId[i] = 0;
            i += 1;
        }
    }
    
    public function EarthBinderGetCurrentTotem(unit u) -> integer {
        return currentTotemId[GetPidofu(u)];
    }
}
//! endzinc
