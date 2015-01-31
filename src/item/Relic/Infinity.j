//! zinc
library Infinity requires ItemAttributes, DamageSystem, Sounds {
#define BUFF_ID 'A065'
    HandleTable ht;

    function onEffect(Buff buf) {
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellTaken -= 0.05;
    }
    
    struct ChainLightning {
        private timer tm;
        private unit caster, target;
        private integer tick;
        private real dmg;
        private group damaged;
        
        private method destroy() {
            ReleaseTimer(this.tm);
            ReleaseGroup(this.damaged);
            this.tm = null;
            this.caster = null;
            this.target = null;
            this.deallocate();
        }
        
        private method getNearestInMobList(unit excl) -> unit {
            unit ret = null;
            real dis = 9999.0;
            real tmp;
            integer i = 0;
            if (MobList.n == 0) {
                return ret;
            } else {
                while (i < MobList.n) {
                    if (!IsUnit(MobList.units[i], excl) && !IsUnitInGroup(MobList.units[i], this.damaged)) {
                        tmp = GetDistance.units2d(excl, MobList.units[i]);
                        if (tmp < dis) {
                            dis = tmp;
                            ret = MobList.units[i];
                        }
                    }
                    i += 1;
                }
                return ret;
            }
        }
        
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            unit next = this.getNearestInMobList(this.target);
            if (next != null) {
                AddTimedLight.atUnits("CLSB", this.target, next, 0.75);
                this.dmg *= 0.5;
                DamageTarget(this.caster, next, this.dmg, "无限-闪电链", false, true, false, WEAPON_TYPE_WHOKNOWS);
                GroupAddUnit(this.damaged, next);
                AddTimedEffect.atUnit(ART_IMPACT, next, "origin", 0.2);
            } else {
                this.tick -= 100;
            }
            this.tick -= 1;
            if (this.tick < 2) {
                this.destroy();
            } else {
                this.target = next;
            }
            next = null;
        }
        
        static method start(unit caster, unit target) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.damaged = NewGroup();
            this.caster = caster;
            this.target = target;
            this.tick = 3;
            AddTimedLight.atUnits("CLPB", this.caster, this.target, 0.75);
            this.dmg = 300.0;
            DamageTarget(this.caster, this.target, this.dmg, "无限-闪电链", false, true, false, WEAPON_TYPE_WHOKNOWS);
            GroupAddUnit(this.damaged, this.target);
            AddTimedEffect.atUnit(ART_IMPACT, this.target, "origin", 0.2);
            TimerStart(this.tm, 0.5, true, function thistype.run);
        }
    }
    
    function damaged() {
        if (DamageResult.isHit) {
            if (ht.exists(DamageResult.source)) {
                if (ht[DamageResult.source] > 0 && !DamageResult.isPhyx) {
                    if (GetRandomInt(0, 99) < 10) {
                        ChainLightning.start(DamageResult.source, DamageResult.target);
                    }
                }
            }
        }
    }
    
    struct ConvictionAura {
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
                while (j < MobList.n) {
                    if (GetDistance.units2d(MobList.units[j], this.u) < 600 && !IsUnitDead(MobList.units[j])) {
                        buf = Buff.cast(this.u, MobList.units[j], BUFF_ID);
                        buf.bd.tick = -1;
                        buf.bd.interval = 1.5;
                        if (buf.bd.i0 != 6) {
                            UnitProp[buf.bd.target].spellTaken += 0.05;
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

    struct InfinityData {
        private static HandleTable infinititab;
        integer life;
        
        static method operator[] (item it) -> thistype {
            thistype this;
            if (!thistype.infinititab.exists(it)) {
                this = thistype.allocate();
                thistype.infinititab[it] = this;
                this.life = 0;
            } else {
                this = thistype.infinititab[it];
            }
            return this;
        }
        
        private static method onInit() {
            thistype.infinititab = HandleTable.create();
        }
    }

    function action(unit u, item it, integer fac) {
        UnitProp up = UnitProp[u];
        InfinityData id = InfinityData[it];
        
        up.ModInt(15 * fac);
        up.spellPower += 15 * fac;
        
        if (fac == 1) {
            id.life = 35 * GetHeroLevel(u);
            RunSoundOnUnit(SND_CONVICTION_AURA, u);
        }
        up.ModLife(id.life * fac);
        
        if (!ht.exists(u)) {ht[u] = 0;}
        ht[u] = ht[u] + fac;
        
        //BJDebugMsg("ht[u] = " + I2S(ht[u]));
        
        ConvictionAura.start(u, ht[u] > 0);
    }
    
    function lvledup() -> boolean {
        unit u = GetTriggerUnit();
        integer i;
        item tmpi;
        ItemPropModType ipmt;
        if (ht.exists(u)) {
            if (ht[u] > 0) {
                ipmt = action;
                i = 0;
                while (i < 6) {
                    tmpi = UnitItemInSlot(u, i);
                    if (GetItemTypeId(tmpi) == ITIDINFINITY) {
                        ipmt.evaluate(u, tmpi, -1);
                        ipmt.evaluate(u, tmpi, 1);
                    }
                    i += 1;
                }
            }
        }
        return false;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterItemPropMod(ITIDINFINITY, action);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        TriggerAnyUnit(EVENT_PLAYER_HERO_LEVEL, function lvledup);
        RegisterDamagedEvent(damaged);
    }
#undef BUFF_ID
}
//! endzinc
