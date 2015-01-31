//! zinc
library Insight requires ItemAttributes, DamageSystem {
#define BUFF_ID 'A066'
    HandleTable ht;

    function onEffect(Buff buf) {
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].manaRegen -= 6.0;
    }
    
    function ondamaging() {
        if (DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0) {
                    DamageResult.wasDodgable = false;
                    DamageResult.isPhyx = false;
                    DamageResult.amount += 45.0;
                }
            }
        }
    }
    
    struct InsightAura {
        private static HandleTable caht;
        private unit u;
        private timer tm;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            thistype.caht.flush(this.u);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            integer j = 0;
            Buff buf;
            if (!IsUnitDead(this.u)) {
                while (j < PlayerUnits.n) {
                    if (GetDistance.units2d(PlayerUnits.units[j], this.u) < 600 && !IsUnitDead(PlayerUnits.units[j])) {
                        buf = Buff.cast(this.u, PlayerUnits.units[j], BUFF_ID);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            UnitProp[buf.bd.target].manaRegen += 6.0;
                            buf.bd.i0 = 6;
                        }
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
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
                //BJDebugMsg("Registered once");
            } else {
                this = thistype.caht[u];
            }
            if (flag) {
                TimerStart(this.tm, 1.0, true, function thistype.run);
            } else {
                //BJDebugMsg("To destroy");
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        
        up.ModInt(12 * fac);
        up.ModAP(15 * fac);
        up.spellPower += 25 * fac;
        up.spellHaste += 0.1 * fac;
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        //BJDebugMsg("ht[u] = " + I2S(ht[u]));
        
        InsightAura.start(u, ht[u] > 0);
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDINSIGHT, action);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterOnDamageEvent(ondamaging);
    }
#undef BUFF_ID
}
//! endzinc
