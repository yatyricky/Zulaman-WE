//! zinc
library Drum requires ItemAttributes {
#define BUFF_ID 'A07C'
#define DEBUFF_ID 'A07B'
#define ART_DEBUFF "Abilities\\Spells\\Other\\Aneu\\AneuTarget.mdl"
    HandleTable ht;

    function oneffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }

    function onremove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    function onEffect1(Buff buf) {
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= 0.02;
        UnitProp[buf.bd.target].healTaken -= 0.1;
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, DEBUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = 3.0;
                    UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
                    buf.bd.r0 = 0.02;
                    if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "overhead");}
                    buf.bd.boe = oneffect;
                    buf.bd.bor = onremove;
                    buf.run();
                }
            }
        }
    }
    
    struct DrumAura {
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
                            UnitProp[buf.bd.target].damageDealt += 0.02;
                            UnitProp[buf.bd.target].healTaken += 0.1;
                            buf.bd.i0 = 6;
                        }
                        buf.bd.boe = onEffect1;
                        buf.bd.bor = onRemove1;
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
                BJDebugMsg("To destroy");
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAttackSpeed(10 * fac);
        //up.ModAP(20 * fac);
        //up.attackCrit += 0.07 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        DrumAura.start(u, ht[u] > 0);
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_DRUM, action);
        RegisterDamagedEvent(damaged);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        BuffType.register(DEBUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
#undef ART_DEBUFF
#undef DEBUFF_ID
#undef BUFF_ID
}
//! endzinc
