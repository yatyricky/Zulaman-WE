//! zinc
library BreathOfTheDying requires DamageSystem, SpellData, AggroSystem {

    constant integer NOMIS = 32;
    HandleTable ht;
    
    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(BID_BREATH_OF_THE_DYING, "BreathOfTheDying.onEffect").name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_POISON, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {}
    
    struct BOTD {
        private timer tm;
        private unit a;
        private unit target;
        private unit mis[NOMIS];
        private integer tick;
        private HandleTable damaged;
        private effect eff[NOMIS];
        private real amount;
        
        private method destroy() {
            integer i = 0;
            while (i < NOMIS) {
                DestroyEffect(this.eff[i]);
                KillUnit(this.mis[i]);
                this.eff[i] = null;
                this.mis[i] = null;
                i += 1;
            }
            ReleaseTimer(this.tm);
            this.tm = null;
            this.damaged.destroy();
            this.a = null;
            this.target = null;
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
                i += 1;
            }
            if (IsInCombat()) {
                j = 0;
                while (j < MobList.n) {
                    if (GetDistance.units2d(MobList.units[j], this.target) < (600 - 24.0 * this.tick) && !IsUnitDead(MobList.units[j]) && this.damaged.exists(MobList.units[j]) == false) {
                        buf = Buff.cast(this.a, MobList.units[j], BID_BREATH_OF_THE_DYING);
                        buf.bd.interval = 1.0 / (1.0 + UnitProp.inst(this.a, SCOPE_PREFIX).SpellHaste() + UnitProp.inst(this.a, SCOPE_PREFIX).AttackSpeed() / 100.0);
                        buf.bd.tick = Rounding(6.0 / buf.bd.interval);
                        buf.bd.r0 = this.amount;
                        buf.bd.boe = onEffect;
                        buf.bd.bor = onRemove;
                        buf.run();
                        this.damaged[MobList.units[j]] = 1;
                    }
                    j += 1;
                }
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
            integer j = 0;
            item iteratorItem;
            UnitProp up = UnitProp.inst(a, "BOTD.start");
            this.a = a;
            this.target = b;
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.tick = 25;
            this.damaged = HandleTable.create();
            this.amount = 0;
            while (j < 6) {
                iteratorItem = UnitItemInSlot(a, j);
                if (GetItemTypeId(iteratorItem) == ITID_BREATH_OF_THE_DYING) {
                    this.amount += ItemExAttributes.getValue(iteratorItem, 50, "BOTD.start");
                }
                j += 1;
            }
            this.amount += (up.AttackPower() + up.SpellPower()) / 40.0;
            while (i < NOMIS) {
                this.mis[i] = CreateUnit(Player(0), DUMMY_ID, GetUnitX(b), GetUnitY(b), Rad2Deg(angle * i));
                SetUnitFlyable(this.mis[i]);
                SetUnitFlyHeight(this.mis[i], 50.0, 0.0);
                this.eff[i] = AddSpecialEffectTarget(ART_POISON_SLIME, this.mis[i], "origin");
                i += 1;
            }
            TimerStart(this.tm, 0.04, true, function thistype.run);
        }
    }
    
    function damaged() {
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                if (GetRandomInt(0, 99) < 15) {
                    BOTD.start(DamageResult.source, DamageResult.target);
                }
            }
        }
    }

    public function EquipedBOTD(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        BuffType.register(BID_BREATH_OF_THE_DYING, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
