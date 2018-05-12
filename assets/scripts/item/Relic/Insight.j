//! zinc
library Insight requires DamageSystem {
    HandleTable ht;
    
    struct InsightAura {
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
            Buff buf;
            integer ii = 0;
            item ti;
            real amt = 0;
            while (ii < 6) {
                ti = UnitItemInSlot(this.u, ii);
                if (ti != null) {
                    amt += ItemExAttributes.getAttributeValue(ti, IATTR_AURA_MEDITA, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX) * 0.14);
                }
                ii += 1;
            }
            ti = null;

            if (!IsUnitDead(this.u)) {
                while (j < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[j], this.u) < 600 && !IsUnitDead(PlayerUnits.units[j])) {
                        ModUnitMana(PlayerUnits.units[j], amt);
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
                this.eff = AddSpecialEffectTarget(ART_BRILLIANCE, u, "origin");
            } else {
                //BJDebugMsg("To destroy");
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }

    public function EquipedInsightAura(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            InsightAura.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            InsightAura.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
        BuffType.register(BID_INSIGHT, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
