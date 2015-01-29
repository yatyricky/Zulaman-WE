//! zinc
library EarthBinderGlobal requires MultipleAbility {
    //public constant integer BUFF_ID_STORM_STRIKE = 'A032';
    public HandleTable freeESAvailability;
    public integer currentTotemId[];
    
    public struct RecoverOriginalEarthShock {
        private static HandleTable ht;
        private timer tm;
        private unit u;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            MultipleAbility[SIDEARTHSHOCK].showPrimary(GetOwningPlayer(this.u));
            
            freeESAvailability.flush(this.u);
            //print("Free earth shock used!");
            
            thistype.ht.flush(this.u);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u  =null;
            this.deallocate();
        }
    
        static method start(unit u, real timeout) {
            thistype this;
            if (thistype.ht.exists(u)) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                thistype.ht[u] = this;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                this.u = u;
            }
            TimerStart(this.tm, timeout, false, function thistype.run);
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function onInit() {
        integer i = 0;
        freeESAvailability = HandleTable.create();
        while (i < NUMBER_OF_MAX_PLAYERS) {
            currentTotemId[i] = 0;
            i += 1;
        }
    }
    
    public function EarthBinderFreeES(unit u) -> boolean {
        return freeESAvailability.exists(u);
    }
    
    public function EarthBinderGetCurrentTotem(unit u) -> integer {
        return currentTotemId[GetPidofu(u)];
    }
}
//! endzinc
