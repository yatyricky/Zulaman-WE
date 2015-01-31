//! zinc
library WindForce requires ItemAttributes, DamageSystem {
    HandleTable ht;
    
    struct KnockBack {
        private timer tm;
        private unit u;
        private integer tick;
        private real x, y;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real newx = GetUnitX(this.u) + this.x;
            real newy = GetUnitY(this.u) + this.y;
            this.tick -= 1;
            if (!IsTerrainWalkable(newx, newy)) {
                this.tick = -1;
            }
            if (this.tick >= 0) {
                SetUnitPosition(this.u, newx, newy);
            } else {
                this.destroy();
            }
        }
    
        static method start(unit u, real ang, real dis) {
            thistype this = thistype.allocate();
            //BJDebugMsg("STARTED");
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = Rounding(dis / 20.0);
            this.x = Cos(ang) * 20.0;
            this.y = Sin(ang) * 20.0;
            //BJDebugMsg(R2S(this.x) + "-" + R2S(this.y));
            this.u = u;
            TimerStart(this.tm, 0.025, true, function thistype.run);
        }
    }
    
    function damaged() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && GetRandomInt(0, 99) < 30 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    if ((GetPlayerId(GetOwningPlayer(DamageResult.target)) != MOB_PID || !IsUnitType(DamageResult.target, UNIT_TYPE_HERO)) && CanUnitAttack(DamageResult.target)) {
                        KnockBack.start(DamageResult.target, GetAngle(GetUnitX(DamageResult.source), GetUnitY(DamageResult.source), GetUnitX(DamageResult.target), GetUnitY(DamageResult.target)), 40.0);
                    }
                }
            }
        }
    }

    function action(unit u, item i, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModAgi(15 * fac);
        up.ModAP(35 * fac);
        up.ModAttackSpeed(15 * fac);
        up.attackCrit += 0.05 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDWINDFORCE, action);
        RegisterDamagedEvent(damaged);
    }
}
//! endzinc
