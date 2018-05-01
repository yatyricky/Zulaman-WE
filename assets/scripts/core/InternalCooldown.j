//! zinc
library InternalCooldown requires TimerUtils {

    private struct ICD {
        private timer tm;
        private InternalCooldown ic;
        private integer aid;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            this.ic.cdtable[this.aid] = 0;
            this.destroy();
        }
        
        static method start(integer aid, real cool, InternalCooldown ic) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.ic = ic;
            this.aid = aid;
            this.ic.cdtable[aid] = 1;
            TimerStart(this.tm, cool, false, function thistype.run);
        }
    }

    private struct InternalCooldown {
        private static HandleTable ht;
        Table cdtable;
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                this.cdtable = Table.create();
                thistype.ht[u] = this;
            } else {
                this = thistype.ht[u];
            }
            return this;
        }
        
        static method start(unit u, integer aid, real cool) {
            thistype this = thistype[u];
            if (!this.cdtable.exists(aid)) {
                this.cdtable[aid] = 0;
            }
            ICD.start(aid, cool, this);
        }
        
        static method cding(unit u, integer aid) -> boolean {
            thistype this = thistype[u];
            if (!this.cdtable.exists(aid)) {
                this.cdtable[aid] = 0;
            }
            return this.cdtable[aid] != 0;
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    public function SetUnitICD(unit u, integer aid, real cool) {
        InternalCooldown.start(u, aid, cool);
    }
    
    public function IsUnitICD(unit u, integer aid) -> boolean {
        return InternalCooldown.cding(u, aid);
    }
}
//! endzinc
