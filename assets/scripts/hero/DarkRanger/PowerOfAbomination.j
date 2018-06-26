//! zinc
library PowerOfAbomination requires DarkRangerGlobal, SpellEvent, DamageSystem {

    constant string TXT_ATP1_BANSHEE_1 = "Power of Banshee(|cffffcc00R|r) - [|cffffcc00Level 1|r]";
    constant string TXT_ATP1_BANSHEE_2 = "Power of Banshee(|cffffcc00R|r) - [|cffffcc00Level 2|r]";
    constant string TXT_ATP1_BANSHEE_3 = "Power of Banshee(|cffffcc00R|r) - [|cffffcc00Level 3|r]";
    constant string TXT_AET1_BANSHEE_1 = "Current: Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 5% and replenishes mana 3 for you.|nSwitch to Power of Abomination: consumes 3 mana per second and summon dark souls to deal 50 magical damage to your target on normal attacks landed.";
    constant string TXT_AET1_BANSHEE_2 = "Current: Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 10% and replenishes mana 5 for you.|nSwitch to Power of Abomination: consumes 5 mana per second and summon dark souls to deal 100 magical damage to your target on normal attacks landed.";
    constant string TXT_AET1_BANSHEE_3 = "Current: Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 15% and replenishes mana 8 for you.|nSwitch to Power of Abomination: consumes 8 mana per second and summon dark souls to deal 200 magical damage to your target on normal attacks landed.";
    constant string TXT_ATP1_ABOMINATION_1 = "Power of Abomination(|cffffcc00R|r) - [|cffffcc00Level 1|r]";
    constant string TXT_ATP1_ABOMINATION_2 = "Power of Abomination(|cffffcc00R|r) - [|cffffcc00Level 2|r]";
    constant string TXT_ATP1_ABOMINATION_3 = "Power of Abomination(|cffffcc00R|r) - [|cffffcc00Level 3|r]";
    constant string TXT_AET1_ABOMINATION_1 = "Current: Power of Abomination: consumes 3 mana per second and summon dark souls to deal 50 magical damage to your target on normal attacks landed.|nSwitch to Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 5% and replenishes mana 3 for you.";
    constant string TXT_AET1_ABOMINATION_2 = "Current: Power of Abomination: consumes 5 mana per second and summon dark souls to deal 100 magical damage to your target on normal attacks landed.|nSwitch to Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 10% and replenishes mana 5 for you.";
    constant string TXT_AET1_ABOMINATION_3 = "Current: Power of Abomination: consumes 8 mana per second and summon dark souls to deal 200 magical damage to your target on normal attacks landed.|nSwitch to Power of Banshee, when normal attacks landed, decrease target's attack accuracy by 15% and replenishes mana 8 for you.";

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

    function returnNumberOfSouls(integer lvl) -> integer {
        if (lvl == 1) {
            return 3;
        } else if (lvl == 2) {
            return 5;
        } else {
            return 7;
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
            thistype this;
            if (thistype.ht.exists(u) == false) {
                this = thistype.allocate();
                this.u = u;
                this.isBanshee = true;
                this.tm = NewTimer();
                SetTimerData(this.tm, this);
                TimerStart(this.tm, 1.0, true, function() {
                    thistype this = GetTimerData(GetExpiredTimer());
                    real amt;
                    if (IsUnitDead(this.u) == true) return;
                    if (this.isBanshee == true) return;
                    amt = returnManaRegen(GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE));
                    ModUnitMana(this.u, 0 - amt);
                    if (GetUnitMana(this.u) < amt) {
                        IssueImmediateOrderById(this.u, SpellData.inst(SID_POWER_OF_BANSHEE, SCOPE_PREFIX).oid);
                    }
                });
                thistype.ht[u] = this;
            } else {
                this = thistype.ht[u];
            }
            return this;
        }

        method updateIconAndText() {
            integer lvl = GetUnitAbilityLevel(this.u, SID_POWER_OF_BANSHEE);
            player p = GetOwningPlayer(this.u);
            if (this.isBanshee) {
                NFSetPlayerAbilityIcon(p, SID_POWER_OF_BANSHEE, BTNPossession);
                if (lvl == 1) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_BANSHEE_1, 1);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_BANSHEE_1, 1);
                } else if (lvl ==2) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_BANSHEE_2, 2);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_BANSHEE_2, 2);
                } else if (lvl == 3) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_BANSHEE_3, 3);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_BANSHEE_3, 3);
                }
            } else {
                NFSetPlayerAbilityIcon(p, SID_POWER_OF_BANSHEE, BTNUnholyFrenzy);
                if (lvl == 1) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_ABOMINATION_1, 1);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_ABOMINATION_1, 1);
                } else if (lvl == 2) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_ABOMINATION_2, 2);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_ABOMINATION_2, 2);
                } else if (lvl == 3) {
                    NFSetPlayerAbilityTooltip(p, SID_POWER_OF_BANSHEE, TXT_ATP1_ABOMINATION_3, 3);
                    NFSetPlayerAbilityExtendedTooltip(p, SID_POWER_OF_BANSHEE, TXT_AET1_ABOMINATION_3, 3);
                }
            }
            p = null;
        }
        
        method abomination() {
            Buff buf;
            integer id;
            this.isBanshee = false;
            // ghoul rage
            id = GetPidofu(this.u);
            if (ghoul[id] != null) {
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
            // update text
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
        if (poa.isBanshee) {
            poa.abomination();
        } else {
            poa.banshee();
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

    function soulsHit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_POWER_OF_BANSHEE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
        return true;
    }

    function darkSoulsDamage(RepeatTask rt) {
        Projectile p = Projectile.create();
        p.caster = rt.u0;
        p.target = rt.u1;
        p.path = rt.s0;
        p.pr = soulsHit;
        p.speed = 500.0;
        p.r0 = rt.r0;
        p.homingMissile();
    }

    function damaged() {
        Buff buf;
        PowerOfAbomination poa;
        RepeatTask rt;
        integer ilvl;
        if (DamageResult.isHit == false) return;
        if (GetUnitTypeId(DamageResult.source) != UTID_DARK_RANGER) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE) == 0) return;

        poa = PowerOfAbomination.inst(DamageResult.source, "damaged");
        ilvl = GetUnitAbilityLevel(DamageResult.source, SID_POWER_OF_BANSHEE);
        if (poa.isBanshee) {
            // curse target
            buf = Buff.cast(DamageResult.source, DamageResult.target, BID_POWER_OF_BANSHEE_CURSE);
            buf.bd.tick = -1;
            buf.bd.interval = 10.0;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "_function_damaged").attackRate += buf.bd.r0;
            buf.bd.r0 = returnMissRate(ilvl);
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_CURSE, buf, "overhead");}
            buf.bd.boe = onEffectCurse;
            buf.bd.bor = onRemoveCurse;
            buf.run();
            // replenishes mana
            ModUnitMana(DamageResult.source, returnManaRegen(ilvl));
        } else {
            rt = RepeatTask.create(darkSoulsDamage, 0.4, returnNumberOfSouls(ilvl));
            rt.u0 = DamageResult.source;
            rt.u1 = DamageResult.target;
            rt.r0 = (returnExtraDamage(ilvl) + UnitProp.inst(rt.u0, SCOPE_PREFIX).SpellPower()) / returnNumberOfSouls(ilvl);
            rt.s0 = ART_AVENGER_MISSILE;
        }
    }

    function learnt() -> boolean {
        PowerOfAbomination poa;
        if (GetLearnedSkill() != SID_POWER_OF_BANSHEE) return false;

        poa = PowerOfAbomination.inst(GetTriggerUnit(), "learnt");
        poa.updateIconAndText();
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
