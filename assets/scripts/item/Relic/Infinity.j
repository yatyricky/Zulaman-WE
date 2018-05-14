//! zinc
library Infinity requires DamageSystem, Sounds {

    HandleTable ht;
    
    struct ConvictionAura {
        private static HandleTable ht;
        private unit u;
        private timer tm;
        effect eff;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.ht.flush(this.u);
            DestroyEffect(this.eff);
            this.eff = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        

        static method onEffect(Buff buf) {
        }

        static method onRemove(Buff buf) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer j = 0;
            Buff buf;
            real amt;
            if (!IsUnitDead(this.u)) {
                amt = ItemExAttributes.getUnitAttrVal(this.u, IATTR_AURA_CONVIC, SCOPE_PREFIX);
                while (j < MobList.n) {
                    if (GetDistance.units2d(MobList.units[j], this.u) < 600 && !IsUnitDead(MobList.units[j])) {
                        buf = Buff.cast(this.u, MobList.units[j], BID_INFINITY);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            buf.bd.r0 = amt;
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += buf.bd.r0;
                            buf.bd.i0 = 6;
                        } else {
                            if (amt > buf.bd.r0) {
                                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += (amt - buf.bd.r0);
                            }
                            buf.bd.r0 = amt;
                        }
                        buf.bd.boe = thistype.onEffect;
                        buf.bd.bor = thistype.onRemove;
                        buf.run();
                    }
                    j += 1;
                }
            }
        }
    
        static method start(unit u, boolean flag) {
            thistype this;
            if (!thistype.ht.exists(u)) {
                this = thistype.allocate();
                thistype.ht[u] = this;
                this.u = u;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
            } else {
                this = thistype.ht[u];
            }
            if (flag) {
                TimerStart(this.tm, 1.0, true, function thistype.run);
                RunSoundOnUnit(SND_CONVICTION_AURA, u);
                this.eff = AddSpecialEffectTarget(ART_VAMPIRIC_AURA, u, "origin");
            } else {
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    public function EquipedConvictionAura(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            ConvictionAura.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            ConvictionAura.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
        BuffType.register(BID_INFINITY, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
