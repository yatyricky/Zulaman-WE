//! zinc
library UnholyAura requires DamageSystem {
    HandleTable ht;
    
    struct UnholyAura {
        private static HandleTable caht;
        private unit u;
        private timer tm;
        effect eff;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.caht.flush(this.u);
            DestroyEffect(this.eff);
            this.eff = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer j = 0;
            real amt;
            if (!IsUnitDead(this.u)) {
                amt = 20;
                while (j < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[j], this.u) < 600 && !IsUnitDead(PlayerUnits.units[j])) {
                        SetWidgetLife(PlayerUnits.units[j], GetWidgetLife(PlayerUnits.units[j]) + amt);
                    }
                    j += 1;
                }
            }
        }
    
        static method start(unit u, boolean flag) {
            thistype this;
            if (!thistype.caht.exists(u)) {
                this = thistype.allocate();
                thistype.caht[u] = this;
                this.u = u;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
            } else {
                this = thistype.caht[u];
            }
            if (flag) {
                TimerStart(this.tm, 1.0, true, function thistype.run);
                this.eff = AddSpecialEffectTarget(ART_UnholyAura, u, "origin");
            } else {
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }

    public function EquipedUnholyAura(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            UnholyAura.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            UnholyAura.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
    }

}
//! endzinc
