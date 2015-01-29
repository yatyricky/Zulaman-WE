//! zinc
library PowerOfAbomination requires DarkRangerGlobal, SpellEvent, DamageSystem {
#define ART "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
#define ART_CURSE "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl"
#define BUFF_ID 'A042'
#define BUFF_ID1 'A043'
#define BUFF_ID2 'A044'
#define ART_LEFT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl"
#define ART_RIGHT "Abilities\\Spells\\Orc\\Bloodlust\\BloodlustSpecial.mdl"

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].attackRate -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].attackRate += buf.bd.r0;
    }

    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(50);
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModAttackSpeed(-50);
    }

    function onEffect2(Buff buf) {}
    function onRemove2(Buff buf) {}
    
    struct PowerOfAbomination {
        static HandleTable ht;
        timer tm;
        boolean isBanshee;
        unit u;
        integer savedAP;
        
        static method operator[] (unit u) -> thistype {
            if (!thistype.ht.exists(u)) {
                BJDebugMsg(SCOPE_PREFIX+">Unregistered unit: " + GetUnitNameEx(u));
                return 0;
            } else {
                return thistype.ht[u];
            }
        }
        
        private static method bansheeRegen() {
            thistype this = GetTimerData(GetExpiredTimer());
            // mana regen amount
            if (!IsUnitDead(this.u)) {
                ModUnitMana(this.u, GetUnitAbilityLevel(this.u, SIDPOWEROFABOMINATION) * 2);
            }
        }
        
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            this.u = u;
            SetTimerData(this.tm, this);
            this.isBanshee = true;
            thistype.ht[u] = this;
            TimerStart(this.tm, 1.0, true, function thistype.bansheeRegen);
        }
        
        method abomination() {
            Buff buf;
            integer id;
            this.isBanshee = false;
            this.savedAP = GetUnitAbilityLevel(this.u, SIDPOWEROFABOMINATION) * 5 + 5;
            UnitProp[this.u].ModAP(this.savedAP);
            //BJDebugMsg("Switched to Abomination!");
            PauseTimer(this.tm);
            
            id = GetPlayerId(GetOwningPlayer(this.u));
            buf = BuffSlot[ghoul[id]].getBuffByBid(BUFF_ID2);
            if (buf == 0 && ghoul[id] != null) {
                // ghoul rage
                buf = Buff.cast(this.u, ghoul[id], BUFF_ID1);
                buf.bd.tick = -1;
                buf.bd.interval = 15;
                UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = 50;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_LEFT, buf, "hand, left");}
                if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
                // tired interval
                buf = Buff.cast(this.u, ghoul[id], BUFF_ID2);
                buf.bd.tick = -1;
                buf.bd.interval = 30;
                buf.bd.boe = onEffect2;
                buf.bd.bor = onRemove2;
                buf.run();
            }
        }
        
        method banshee() {
            //BJDebugMsg("Switched to Banshee!");
            this.isBanshee = true;
            UnitProp[this.u].ModAP(0 - this.savedAP);
            this.savedAP = 0;
            TimerStart(this.tm, 1.0, true, function thistype.bansheeRegen);
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function onCast() -> boolean {        
        unit u = GetTriggerUnit();
        integer pid = GetPlayerId(GetOwningPlayer(u));
        if (GetUnitTypeId(u) == UTIDDARKRANGER) {
            if (GetIssuedOrderId() == OID_IMMOLATIONON) {
                PowerOfAbomination[u].abomination();
            } else if (GetIssuedOrderId() == OID_IMMOLATIONOFF) {
                //BJDebugMsg("immolation off");
                PowerOfAbomination[u].banshee();
            }
        }
        u = null;
        return false;
    }
    
    function learnt() -> boolean {
        if (GetLearnedSkill() == SIDPOWEROFABOMINATION) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDPOWEROFABOMINATION) == 1) {
                PowerOfAbomination.start(GetTriggerUnit());
            }
        }
        return false;
    }
    
    public function DarkRangerIsAbominationOn(unit u) -> boolean {
        return (!PowerOfAbomination[u].isBanshee);
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit && GetUnitTypeId(DamageResult.source) == UTIDDARKRANGER) {
            if (GetUnitAbilityLevel(DamageResult.source, SIDPOWEROFABOMINATION) > 0 && !PowerOfAbomination[DamageResult.source].isBanshee) {
                DestroyEffect(AddSpecialEffectTarget(ART, DamageResult.target, "origin"));
            }
            if (GetUnitAbilityLevel(DamageResult.source, SIDPOWEROFABOMINATION) > 1 && PowerOfAbomination[DamageResult.source].isBanshee) {
                buf = Buff.cast(DamageResult.source, DamageResult.target, BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                UnitProp[buf.bd.target].attackRate += buf.bd.r0;
                buf.bd.r0 = 0.05 * GetUnitAbilityLevel(DamageResult.source, SIDPOWEROFABOMINATION) - 0.05;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }
    /*
    function drDeath(unit u) {
        if (GetUnitTypeId(u) == UTIDDARKRANGER) {
            if (GetUnitAbilityLevel(u, SIDPOWEROFABOMINATION) > 0) {
                if (!PowerOfAbomination[u].isBanshee) {
                    BJDebugMsg("Bug –ŒÃ¨À¿Õˆ");
                    PowerOfAbomination[u].banshee();
                }
            }
        }
    }*/

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_POS);
        BuffType.register(BUFF_ID2, BUFF_PHYX, BUFF_NEG);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function learnt);
        RegisterDamagedEvent(damaged);
        //RegisterUnitDeath(drDeath);
    }
#undef ART_RIGHT
#undef ART_LEFT
#undef BUFF_ID2
#undef BUFF_ID1
#undef BUFF_ID
#undef ART_CURSE
#undef ART
}
//! endzinc
