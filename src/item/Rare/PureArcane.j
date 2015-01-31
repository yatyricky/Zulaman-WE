//! zinc
library PureArcane requires ItemAttributes {
#define ART_TARGET "Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl"
    HandleTable ht;
    
    struct PureArcaneCharges {
        private static HandleTable ht;
        private item it;
        private timer tm;
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            thistype.ht.flush(this.it);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.it = null;
            this.deallocate();
        }
        
        static method start(item it, unit caster, unit target) {
            thistype this;
            if (!thistype.ht.exists(it)) {
                SetItemCharges(it, GetItemCharges(it) + 1);
                if (GetItemCharges(it) == 3) {
                    DelayedDamageTarget(caster, target, 300.0 + UnitProp[caster].SpellPower(), "´¿¾»ÃØ·¨", false, true, false, WEAPON_TYPE_WHOKNOWS);
                    AddTimedLight.atUnits("MFPB", caster, target, 0.75);
                    AddTimedEffect.atUnit(ART_TARGET, target, "origin", 1.0);
                    SetItemCharges(it, 0);
                }
                this = thistype.allocate();
                thistype.ht[it] = this;
                this.it = it;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                TimerStart(this.tm, 1.0, false, function thistype.run);
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function damaged() {
        integer i;
        item tmpi;
        if (DamageResult.isHit && !DamageResult.isPhyx && DamageResult.isCritical) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0) {
                    i = 0;
                    while (i < 6) {
                        tmpi = UnitItemInSlot(DamageResult.source, i);
                        if (GetItemTypeId(tmpi) == ITID_PURE_ARCANE) {
                            PureArcaneCharges.start(tmpi, DamageResult.source, DamageResult.target);
                        }
                        i += 1;
                    }
                    tmpi = null;
                }
            }
        }
    }

    function action(unit u, item it, integer fac) {
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITID_PURE_ARCANE, action);
        RegisterDamagedEvent(damaged);
    }
#undef ART_TARGET
}
//! endzinc
