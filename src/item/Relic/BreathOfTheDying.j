//! zinc
library BreathOfTheDying requires ItemAttributes, DamageSystem, SpellData, AggroSystem {
#define MISSILE "Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl"
#define BUFF_ID 'A063'
#define NOMIS 32
    HandleTable ht;
    
    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, 30.0, "死亡呼吸", false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {}
    
    struct BOTD {
        private timer tm;
        private unit a;
        private unit mis[NOMIS];
        private integer tick;
        private group damaged;
        private effect eff[NOMIS];
        
        private method destroy() {
            integer i = 0;
            while (i < NOMIS) {
                DestroyEffect(this.eff[i]);
                KillUnit(this.mis[i]);
                this.eff[i] = null;
                this.mis[i] = null;
                i += 1;
            }
            ReleaseGroup(this.damaged);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.damaged = null;
            this.a = null;
            this.deallocate();
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            real nextx;
            real nexty;
            real angle = 6.283 / NOMIS;
            integer i = 0;
            integer j;
            Buff buf;
            while (i < NOMIS) {
                nextx = GetUnitX(this.mis[i]) + Cos(angle * i) * 24.0;
                nexty = GetUnitY(this.mis[i]) + Sin(angle * i) * 24.0;
                SetUnitX(this.mis[i], nextx);
                SetUnitY(this.mis[i], nexty);
                
                if (IsInCombat()) {
                    j = 0;
                    while (j < MobList.n) {
                        if (GetDistance.units2d(MobList.units[j], this.mis[i]) < 150 && !IsUnitDead(MobList.units[j]) && !IsUnitInGroup(MobList.units[j], this.damaged)) {
                            buf = Buff.cast(this.a, MobList.units[j], BUFF_ID);
                            buf.bd.interval = 1.0 / (1.0 + UnitProp[this.a].SpellHaste() + UnitProp[this.a].AttackSpeed() / 100.0);
                            buf.bd.tick = Rounding(6.0 / buf.bd.interval);
                            buf.bd.boe = onEffect;
                            buf.bd.bor = onRemove;
                            buf.run();
                            GroupAddUnit(this.damaged, MobList.units[j]);
                        }
                        j += 1;
                    }
                }
                
                i += 1;
            }
            if (this.tick > 0) {
                this.tick -= 1;
            } else {
                this.destroy();
            }
        }
        
        static method start(unit a, unit b) {
            thistype this = thistype.allocate();
            real angle = 6.283 / NOMIS;
            integer i = 0;
            this.a = a;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = 25;
            this.damaged = NewGroup();
            while (i < NOMIS) {
                this.mis[i] = CreateUnit(Player(0), DUMMY_ID, GetUnitX(b), GetUnitY(b), Rad2Deg(angle * i));
                SetUnitFlyable(this.mis[i]);
                SetUnitFlyHeight(this.mis[i], 50.0, 0.0);
                //SetUnitScale(this.mis, 2.0, 2.0, 2.0);
                this.eff[i] = AddSpecialEffectTarget(MISSILE, this.mis[i], "origin");
                i += 1;
            }
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }
    
    function damaged() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
                    if (GetRandomInt(0, 99) < 15) {
                        BOTD.start(DamageResult.source, DamageResult.target);
                    }
                }
            }
        }
    }

    function action(unit u, item i, integer fac) {
        UnitProp up = UnitProp[u];
        up.ModStr(10 * fac);
        up.ModAgi(10 * fac);
        up.ModInt(10 * fac);
        up.ModAP(40 * fac);
        up.ModAttackSpeed(20 * fac);
        up.ll += 0.1 * fac;
        up.ml += 0.1 * fac;
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDBREATHOFTHEDYING, action);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(damaged);
    }
#undef NOMIS
#undef BUFF_ID
#undef MISSILE
}
//! endzinc
