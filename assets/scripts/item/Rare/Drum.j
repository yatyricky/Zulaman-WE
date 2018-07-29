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
            BlzSetSpecialEffectAlpha(this.eff, 0);
            DestroyEffect(this.eff);
            this.eff = null;
            this.tm = null;
            this.u = null;
            this.deallocate();
        }

        static method onRemove(Buff buf) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r1;
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer i = 0;
            Buff buf;
            real damp, hamp;
            if (!IsUnitDead(this.u)) {
                damp = ItemExAttributes.getUnitAttrVal(this.u, IATTR_AURA_WARSONG, SCOPE_PREFIX);
                hamp = 0.1;
                while (i < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[i], this.u) < 600 && !IsUnitDead(PlayerUnits.units[i])) {
                        buf = Buff.cast(this.u, PlayerUnits.units[i], BID_WARSONG_AURA);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.1;
                        if (buf.bd.r0 < hamp) {
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += (hamp - buf.bd.r0);
                            buf.bd.r0 = hamp;
                        }
                        if (buf.bd.r1 < damp) {
                            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += (damp - buf.bd.r1);
                            buf.bd.r1 = damp;
                        }
                        buf.bd.boe = Buff.noEffect;
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
