//! zinc
library Drum requires BuffSystem {

    HandleTable ht;

    struct WarsongAura {
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
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= 0.1;
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            Buff buf;
            real amt;
            if (!IsUnitDead(this.u)) {
                amt = ItemExAttributes.getUnitAttributeValue(this.u, IATTR_AURA_WARSONG, 0.07, SCOPE_PREFIX);
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.u) < 600 && !IsUnitDead(PlayerUnits.units[i])) {
                        buf = Buff.cast(this.u, PlayerUnits.units[i], BID_WARSONG_AURA);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            buf.bd.r0 = amt;
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += 0.1;
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += amt;
                            buf.bd.i0 = 6;
                        } else {
                            if (amt > buf.bd.r0) {
                                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += (amt - buf.bd.r0);
                            }
                            buf.bd.r0 = amt;
                        }
                        buf.bd.boe = thistype.onEffect;
                        buf.bd.bor = thistype.onRemove;
                        buf.run();
                    }
                    i += 1;
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
                this.eff = AddSpecialEffectTarget(ART_DRUMS_CASTER_HEAL, u, "origin");
            } else {
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    public function EquipedWarsongAura(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            WarsongAura.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            WarsongAura.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
        BuffType.register(BID_WARSONG_AURA, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
