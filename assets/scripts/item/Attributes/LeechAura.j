//! zinc
library LeechAura requires DamageSystem, Projectile {
    HandleTable ht;

    function lifeLeechOnHit(Projectile p) -> boolean {
        HealTarget(p.u0, p.u0, p.r0, SpellData.inst(SID_LEECH_AURA, SCOPE_PREFIX).name, 0.0, false);
        return true;
    }
    
    struct LeechAura {
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
            integer i = 0;
            real amt;
            Projectile p;
            if (!IsUnitDead(this.u)) {
                amt = ItemExAttributes.getUnitAttrVal(this.u, IATTR_LEECHAURA, SCOPE_PREFIX);
                while (i < MobList.n) {
                    if (GetDistance.units2d(MobList.units[i], this.u) < 600 && !IsUnitDead(MobList.units[i])) {
                        DamageTarget(this.u, MobList.units[i], amt, SpellData.inst(SID_LEECH_AURA, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);

                        p = Projectile.create();
                        p.caster = MobList.units[i];
                        p.target = this.u;
                        p.path = ART_ZigguratMissile;
                        p.pr = lifeLeechOnHit;
                        p.speed = 400.0;
                        p.r0 = amt;
                        p.u0 = this.u;
                        p.homingMissile();
                    }
                    i += 1;
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
            } else {
                this.destroy();
            }
        }
        
        private static method onInit() {
            thistype.caht = HandleTable.create();
        }
    }

    public function EquipedLeechAura(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        if (ht[u] == 0) {
            LeechAura.start(u, true);
        }
        ht[u] = ht[u] + polar;
        if (ht[u] == 0) {
            LeechAura.start(u, false);
        }
    }

    function onInit() {
        ht = HandleTable.create();
    }

}
//! endzinc
