//! zinc
library PowerOfAbomination requires DarkRangerGlobal, SpellEvent, DamageSystem {

    constant string TXT_CN_AET1_BANSHEE_1 = "当前激活：女妖之力，每秒恢复3点法力值，攻击附加诅咒效果，使敌人的攻击有5%的几率落空。|n可以切换至憎恶之力，每秒消耗3点法力值，你的每次攻击会召唤幽魂对你的目标造成50点额外伤害，同时提升食尸鬼的20%攻击速度。";
    constant string TXT_CN_AET1_BANSHEE_2 = "当前激活：女妖之力，每秒恢复5点法力值，攻击附加诅咒效果，使敌人的攻击有10%的几率落空。|n可以切换至憎恶之力，每秒消耗5点法力值，你的每次攻击会召唤幽魂对你的目标造成100点额外伤害，同时提升食尸鬼的40%攻击速度。";
    constant string TXT_CN_AET1_BANSHEE_3 = "当前激活：女妖之力，每秒恢复8点法力值，攻击附加诅咒效果，使敌人的攻击有15%的几率落空。|n可以切换至憎恶之力，每秒消耗8点法力值，你的每次攻击会召唤幽魂对你的目标造成200点额外伤害，同时提升食尸鬼的80%攻击速度。";
    constant string TXT_CN_AET1_ABOMINATION_1 = "当前激活：憎恶之力，每秒消耗3点法力值，你的每次攻击会召唤幽魂对你的目标造成50点额外伤害，同时提升食尸鬼的20%攻击速度。|n可以切换至女妖之力，每秒恢复3点法力值，攻击附加诅咒效果，使敌人的攻击有5%的几率落空。";
    constant string TXT_CN_AET1_ABOMINATION_2 = "当前激活：憎恶之力，每秒消耗5点法力值，你的每次攻击会召唤幽魂对你的目标造成100点额外伤害，同时提升食尸鬼的40%攻击速度。|n可以切换至女妖之力，每秒恢复5点法力值，攻击附加诅咒效果，使敌人的攻击有10%的几率落空。";
    constant string TXT_CN_AET1_ABOMINATION_3 = "当前激活：憎恶之力，每秒消耗8点法力值，你的每次攻击会召唤幽魂对你的目标造成200点额外伤害，同时提升食尸鬼的80%攻击速度。|n可以切换至女妖之力，每秒恢复8点法力值，攻击附加诅咒效果，使敌人的攻击有15%的几率落空。";

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
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function_onEffectCurse").attackRate -= buf.bd.r0;
    }

    function onRemoveCurse(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function_onRemoveCurse").attackRate += buf.bd.r0;
    }

    function onEffectFrenzy(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function onEffectFrenzy").ModAttackSpeed(buf.bd.i0);
    }

    function onRemoveFrenzy(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function onRemoveFrenzy").ModAttackSpeed(0 - buf.bd.i0);
    }

    struct PowerOfAbomination {
        static HandleTable ht;
        timer tm;
        boolean isBanshee;
        unit u;
        
        static method inst(unit u, string trace) -> thistype {
            if (!thistype.ht.exists(u)) {
                print(SCOPE_PREFIX + " unregistered unit: " + GetUnitNameEx(u) + ", trace: " + trace);
                return 0;
            } else {
                return thistype.ht[u];
            }
        }
        
        private static method bansheeRegen() {
            thistype this = GetTimerData(GetExpiredTimer());
            real amt;
            // mana regen amount
            if (!IsUnitDead(this.u)) {
                amt = returnManaRegen(GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE));
                if (this.isBanshee) {
                    ModUnitMana(this.u, amt);
                } else {
                    ModUnitMana(this.u, 0 - amt);
                    if (GetUnitMana(this.u) < amt) {
                        IssueImmediateOrderById(this.u, SpellData.inst(SID_POWER_OF_BANSHEE, SCOPE_PREFIX).oid);
                    }
                }
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

        method updateIconAndText() {
            integer lvl = GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE);
            if (this.isBanshee) {
                NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, BTNPossession);
                if (lvl == 1) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_BANSHEE_1, 1);
                } else if (lvl ==2) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_BANSHEE_2, 2);
                } else if (lvl == 3) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_BANSHEE_3, 3);
                }
            } else {
                NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, BTNUnholyFrenzy);
                if (lvl == 1) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_ABOMINATION_1, 1);
                } else if (lvl == 2) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_ABOMINATION_2, 2);
                } else if (lvl == 3) {
                    NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_POWER_OF_BANSHEE, TXT_CN_AET1_ABOMINATION_3, 3);
                }
            }
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
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "method_abomination").ModAttackSpeed(0 - buf.bd.i0);
                buf.bd.i0 = returnAttackSpeed(GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE));
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");}
                if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffectFrenzy;
                buf.bd.bor = onRemoveFrenzy;
                buf.run();
            }
            this.updateIconAndText();
        }
        
        method banshee() {
            Buff buf;
            BuffSlot bs;
            integer id = GetPidofu(this.u);
            this.isBanshee = true;
            if (ghoul[id] != null) {
                bs = BuffSlot[ghoul[id]];
                buf = bs.getBuffByBid(BID_POWER_OF_BANSHEE_FRENZY);
                if (buf != 0) {
                    bs.dispelByBuff(buf);
                    buf.destroy();
                }
            }
            this.updateIconAndText();
        }
        
        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function onCast() {
        PowerOfAbomination poa = PowerOfAbomination.inst(SpellEvent.CastingUnit, "onCast");
        if (poa != 0) {
            if (poa.isBanshee) {
                poa.abomination();
            } else {
                poa.banshee();
            }
        }
    }
    
    public function DarkRangerIsAbominationOn(unit u) -> boolean {
        PowerOfAbomination poa = PowerOfAbomination.inst(u, "DarkRangerIsAbominationOn");
        if (poa != 0) {
            return !poa.isBanshee;
        } else {
            return false;
        }
    }
    
    function damaged() {
        Buff buf;
        PowerOfAbomination poa;
        if (DamageResult.isHit && GetUnitTypeId(DamageResult.source) == UTID_DARK_RANGER && DamageResult.abilityName != SpellData.inst(SID_POWER_OF_BANSHEE, SCOPE_PREFIX).name && GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE) > 0) {
            poa = PowerOfAbomination.inst(DamageResult.source, "damaged");
            if (poa != 0) {
                if (poa.isBanshee) {
                    buf = Buff.cast(DamageResult.source, DamageResult.target, BID_POWER_OF_BANSHEE_CURSE);
                    buf.bd.tick = -1;
                    buf.bd.interval = 10.0;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function_damaged").attackRate += buf.bd.r0;
                    buf.bd.r0 = returnMissRate(GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE));
                    if (buf.bd.e0 == 0) {
                        buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");
                    }
                    buf.bd.boe = onEffectCurse;
                    buf.bd.bor = onRemoveCurse;
                    buf.run();
                } else {
                    DestroyEffect(AddSpecialEffectTarget(ART_AVENGER_MISSILE, DamageResult.target, "origin"));
                    DamageTarget(DamageResult.source, DamageResult.target, returnExtraDamage(GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE)), SpellData.inst(SID_POWER_OF_BANSHEE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                }
            }
        }
    }
    
    function learnt() -> boolean {
        PowerOfAbomination poa;
        if (GetLearnedSkill() == SID_POWER_OF_BANSHEE) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SID_POWER_OF_BANSHEE) == 1) {
                PowerOfAbomination.start(GetTriggerUnit());
            } else {
                poa = PowerOfAbomination.inst(GetTriggerUnit(), "learnt");
                if (poa != 0) {
                    poa.updateIconAndText();
                }
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
