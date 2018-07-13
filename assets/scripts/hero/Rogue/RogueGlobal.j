//! zinc
library RogueGlobal requires Table, ZAMCore, FloatingNumbers {

    public struct ComboPoints {
        private static HandleTable ht;
        private static unit comboPointDummies[];
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
            integer pid = GetPidofu(this.u);
            if (thistype.comboPointDummies[pid] == null) {
                thistype.comboPointDummies[pid] = CreateUnit(GetOwningPlayer(this.u), UTID_COMBO_POINTS, DUMMY_X, DUMMY_Y, 0);
            }
            this.n += i;
            if (this.n > 5) {
                this.n = 5;
            }
            if (GetLocalPlayer() == GetOwningPlayer(this.u)) {
                FloatingNumbers.create(I2S(this.n) + " combo", COLOR_DAMAGE_CRITICAL, GetUnitX(this.u), GetUnitY(this.u), 1.7, false);
            } else {
                FloatingNumbers.create(NULL_STR, COLOR_DAMAGE_CRITICAL, GetUnitX(this.u), GetUnitY(this.u), 1.7, false);
            }
        }
        
        method get() -> integer {
            integer j = this.n;
            integer pid = GetPidofu(this.u);
            KillUnit(thistype.comboPointDummies[pid]);
            thistype.comboPointDummies[pid] = null;
            this.n = 0;
            return j;
        }
        
        private static method onInit() {
            integer i;
            thistype.ht = HandleTable.create();
            i = 0;
            while (i < NUMBER_OF_MAX_PLAYERS) {
                thistype.comboPointDummies[i] = null;
                i += 1;
            }
        }
    }

}
//! endzinc
