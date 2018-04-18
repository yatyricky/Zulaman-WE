//! zinc
library PowerOfAbomination requires DarkRangerGlobal, SpellEvent, DamageSystem {

    function returnManaRegen(integer lvl) -> real {
        if (lvl == 1) {
            return 3.0;
        } else if (lvl == 2) {
            return 5.0;
        } else {
            return 8.0;
        }
    }

    function returnExtraDamage(integer lvl) -> real {
        if (lvl == 1) {
            return 50.0;
        } else if (lvl == 2) {
            return 100.0;
        } else {
            return 200.0;
        }
    }

    function returnMissRate(integer lvl) -> real {
        if (lvl == 1) {
            return 0.05;
        } else if (lvl == 2) {
            return 0.1;
        } else {
            return 0.15;
        }
    }

    function returnAttackSpeed(integer lvl) -> integer {
        if (lvl == 1) {
            return 20;
        } else if (lvl == 2) {
            return 40;
        } else {
            return 80;
        }
    }

    function onEffectCurse(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate -= buf.bd.r0;
    }

    function onRemoveCurse(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
    }

    function onEffectFrenzy(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemoveFrenzy(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }

    function onEffect2(Buff buf) {}
    function onRemove2(Buff buf) {}
    
    struct PowerOfAbomination {
        static HandleTable ht;
        timer tm;
        boolean isBanshee;
        unit u;
        
        static method inst(unit u) -> thistype {
            if (!thistype.ht.exists(u)) {
                print(SCOPE_PREFIX+">Unregistered unit: " + GetUnitNameEx(u));
                return 0;
            } else {
                return thistype.ht[u];
            }
        }
        
        private static method bansheeRegen() {
            thistype this = GetTimerData(GetExpiredTimer());
            // mana regen amount
            if (!IsUnitDead(this.u)) {
                ModUnitMana(this.u, returnManaRegen(GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE)));
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
            
            id = GetPidofu(this.u);
            if (ghoul[id] != null) {
                // ghoul rage
                buf = Buff.cast(this.u, ghoul[id], BID_POWER_OF_BANSHEE_FRENZY);
                buf.bd.tick = -1;
                buf.bd.interval = 300;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = returnAttackSpeed(GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE));
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");}
                if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffectFrenzy;
                buf.bd.bor = onRemoveFrenzy;
                buf.run();
            }
        }
        
        method banshee() {
            Buff buf;
            BuffSlot bs;
            integer id;
            this.isBanshee = true;
            id = GetPidofu(this.u);
            if (ghoul[id] != null) {
                bs = BuffSlot[ghoul[id]];
                buf = bs.getBuffByBid(BID_POWER_OF_BANSHEE_FRENZY);
                if (buf != 0) {
                    bs.dispelByBuff(buf);
                    buf.destroy();
                }
            }
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function onCast() {
        PowerOfAbomination poa = PowerOfAbomination.inst(SpellEvent.CastingUnit);
        if (poa != 0) {
            if (poa.isBanshee) {
                poa.abomination();
            } else {
                poa.banshee();
            }
        }
    }
    
    public function DarkRangerIsAbominationOn(unit u) -> boolean {
        PowerOfAbomination poa = PowerOfAbomination.inst(SpellEvent.CastingUnit);
        if (poa != 0) {
            return !poa.isBanshee;
        } else {
            return false;
        }
    }
    
    function damaged() {
        Buff buf;
        PowerOfAbomination poa;
        if (DamageResult.isHit && GetUnitTypeId(DamageResult.source) == UTID_DARK_RANGER && DamageResult.abilityName != SpellData[SID_POWER_OF_BANSHEE].name) {
            poa = PowerOfAbomination.inst(DamageResult.source);
            if (poa != 0) {
                if (poa.isBanshee) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BID_POWER_OF_BANSHEE_CURSE);
                    buf.bd.tick = -1;
                    buf.bd.interval = 10.0;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackRate += buf.bd.r0;
                    buf.bd.r0 = returnMissRate(GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE));
                    if (buf.bd.e0 == 0) {
                        buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
                    }
                    buf.bd.boe = onEffectCurse;
                    buf.bd.bor = onRemoveCurse;
                    buf.run();
                } else {
                    DestroyEffect(AddSpecialEffectTarget(ART_AVENGER_MISSILE, DamageResult.target, "origin"));
                    DamageTarget(DamageResult.source, DamageResult.target, returnExtraDamage(GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE)), SpellData[SID_POWER_OF_BANSHEE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                }
            }
            
        }
    }
    
    function learnt() -> boolean {
        if (GetLearnedSkill() == SID_POWER_OF_BANSHEE) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_POWER_OF_BANSHEE) == 1) {
                PowerOfAbomination.start(GetTriggerUnit());
            }
        }
        return false;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_POWER_OF_BANSHEE, onCast);
        BuffType.register(BID_POWER_OF_BANSHEE_CURSE, BUFF_MAGE, BUFF_NEG);
        BuffType.register(BID_POWER_OF_BANSHEE_FRENZY, BUFF_PHYX, BUFF_POS);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function learnt);
        RegisterDamagedEvent(damaged);
    }

}
//! endzinc
