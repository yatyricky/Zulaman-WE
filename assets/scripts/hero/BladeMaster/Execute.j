//! zinc
library Execute requires DamageSystem, AggroSystem {
    public constant integer BM_VALOUR_MAX = 17;
    public constant string TXT_CN_AET1_EXECUTE_0 = "当普通攻击，英勇打击，或者致死打击暴击之后，增加勇气点数和";
    public constant string TXT_CN_AET1_EXECUTE_1 = "点法力值。|n连续的暴击会使勇气点数成倍增长。|n勇气点数越多，你的斩杀之刃会越灼热，造成的伤害也越高。|n战斗中每";
    public constant string TXT_CN_AET1_EXECUTE_2 = "秒会自动获得少量勇气点数。|n|n|cff99ccff勇气点数: |r";

    function returnTimerInterval(integer lvl) -> real {
        return 6.0 - lvl;
    }
    
    function returnDamagePerPoint(integer lvl) -> real {
        return 40.0;
    }
    
    function returnManaRegen(integer lvl) -> real {
        return 2.0 + lvl;
    }
    
    struct ValourManager {
        static HandleTable ht;
        private timer tm;
        private unit u;
        integer continuous;
        integer valour;

        method forgeAET() -> string {
            integer lvl = GetUnitAbilityLevel(this.u, SID_EXECUTE);
            return TXT_CN_AET1_EXECUTE_0 + I2S(R2I(returnManaRegen(lvl))) + TXT_CN_AET1_EXECUTE_1 + I2S(R2I(returnTimerInterval(lvl))) + TXT_CN_AET1_EXECUTE_2 + I2S(this.valour);
        }

        static method inst(unit u, string trace) -> thistype {
            if (thistype.ht.exists(u)) {
                return thistype.ht[u];
            } else {
                // print("Unregistered Blademaster: " + trace);
                return 0;
            }
        }

        method flushValour() -> integer {
            integer ret = this.valour;
            this.valour = 0;
            NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_EXECUTE, BTNExecute0);
            NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_EXECUTE, this.forgeAET(), GetUnitAbilityLevel(this.u, SID_EXECUTE));
            return ret;
        }

        method getValour() -> integer {
            return this.valour;
        }
        
        method increaseValour(integer n) {
            integer show;
            string path;
            this.valour += n;
            if (this.valour > BM_VALOUR_MAX) {
                this.valour = BM_VALOUR_MAX;
            }
            show = (this.valour + 3) / 4;
            if (show == 0) {
                path = BTNExecute0;
            } else if (show == 1) {
                path = BTNExecute1;
            } else if (show == 2) {
                path = BTNExecute2;
            } else if (show == 3) {
                path = BTNExecute3;
            } else if (show == 4) {
                path = BTNExecute4;
            }
            NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_EXECUTE, path);
            NFSetPlayerAbilityExtendedTooltip(GetOwningPlayer(this.u), SID_EXECUTE, this.forgeAET(), GetUnitAbilityLevel(this.u, SID_EXECUTE));
        }
    
        private static method increaseValourExe() {
            thistype this = GetTimerData(GetExpiredTimer());
            real timeout = returnTimerInterval(GetUnitAbilityLevel(this.u, SID_EXECUTE_LEARN));
            if (IsInCombat()) {
                this.increaseValour(1);
            }
            if (TimerGetTimeout(this.tm) > timeout) {
                TimerStart(this.tm, timeout, true, function thistype.increaseValourExe);
            }
        }

        static method start(unit u) {
            thistype this = thistype.allocate();
            this.tm = NewTimer();
            SetTimerData(this.tm, this);
            this.u = u;
            this.continuous = 1;
            this.valour = 0;
            thistype.ht[u] = this;
            TimerStart(this.tm, returnTimerInterval(GetUnitAbilityLevel(u, SID_EXECUTE_LEARN)), true, function thistype.increaseValourExe);
        }

        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }
    
    function damaged() {
        integer id;
        integer lvl;
        real mana;
        ValourManager vm;
        lvl = GetUnitAbilityLevel(DamageResult.source, SID_EXECUTE_LEARN);
        if (lvl > 0) {
            mana = returnManaRegen(lvl);
            if (DamageResult.abilityName == DAMAGE_NAME_MELEE || DamageResult.abilityName == SpellData.inst(SID_MORTAL_STRIKE, SCOPE_PREFIX).name || DamageResult.abilityName == SpellData.inst(SID_HEROIC_STRIKE, SCOPE_PREFIX).name) {
                vm = ValourManager.inst(DamageResult.source, "damaged");
                if (vm.continuous == 1) {
                    if (DamageResult.isCritical) {
                        vm.increaseValour(vm.continuous);
                        ModUnitMana(DamageResult.source, mana);
                        vm.continuous *= 2;
                    }
                } else {
                    if (DamageResult.isCritical) {
                        vm.increaseValour(vm.continuous);
                        ModUnitMana(DamageResult.source, mana);
                        vm.continuous *= 2;
                    } else {
                        vm.continuous = 1;
                    }
                }
            }
        }
    }
    
    function onCast() {
        integer v = ValourManager.inst(SpellEvent.CastingUnit, "onCast").flushValour();
        real dmg = v * returnDamagePerPoint(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EXECUTE_LEARN)) + (UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * v * 0.1);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_EXECUTE_LEARN, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
        AddTimedEffect.atUnit(ART_GORE, SpellEvent.TargetUnit, "origin", 0.3);
    }

    public function GetUnitValour(unit u) -> integer {
        ValourManager vm = ValourManager.inst(u, "GetValour");
        if (vm != 0) {
            return vm.getValour();
        } else {
            return 0;
        }
    }

    function level() -> boolean {
        unit u;
        integer lvl;
        if (GetLearnedSkill() == SID_EXECUTE_LEARN) {
            u = GetTriggerUnit();
            lvl = GetUnitAbilityLevel(u, SID_EXECUTE_LEARN);
            if (lvl == 1) {
                UnitAddAbility(u, SID_EXECUTE);
                ValourManager.start(u);
            } else {
                SetUnitAbilityLevel(u, SID_EXECUTE, lvl);
            }
        }
        u = null;
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);            // learnt
        RegisterDamagedEvent(damaged);            // detect critical
        RegisterSpellEffectResponse(SID_EXECUTE, onCast);
    }
}
//! endzinc
