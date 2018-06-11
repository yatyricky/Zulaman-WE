//! zinc
library RogueGlobal requires Table, ZAMCore, FloatingNumbers {
    public struct ComboPoints {
        private static HandleTable ht;
        integer n;
        unit u;
        
        static method operator[] (unit u) -> thistype {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                this.n = 0;
                this.u = u;
                thistype.ht[u] = this;
            }
            return thistype.ht[u];
        }
        
        method add(integer i) {
            this.n += i;
            if (this.n > 5) {
                this.n = 5;
            }
            FloatingNumbers.create(I2S(this.n) + " combo", COLOR_DAMAGE_CRITICAL, GetUnitX(this.u), GetUnitY(this.u), 1.7, false);
        }
        
        method get() -> integer {
            integer j = this.n;
            this.n = 0;
            return j;
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function responseenteredmap(unit u) {
        player p = null;
        if (GetUnitTypeId(u) == UTID_ROGUE) {
            p = GetOwningPlayer(u);
            SetPlayerAbilityAvailable(p, SID_GARROTE, false);
            SetPlayerAbilityAvailable(p, SID_AMBUSH, false);
            p  = null;
        }
    }
    
    function onInit() {
        RegisterUnitEnterMap(responseenteredmap);
    }
}
//! endzinc
