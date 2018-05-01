//! zinc
library KeeperOfGroveGlobal {
    public real lbexcrit[NUMBER_OF_MAX_PLAYERS];
    public integer rejuvtick[NUMBER_OF_MAX_PLAYERS];
    public integer lbtick[NUMBER_OF_MAX_PLAYERS];
    
    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            lbexcrit[i] = 0.0;
            rejuvtick[i] = 4;
            lbtick[i] = 7;
            i += 1;
        }
    }
}
//! endzinc
