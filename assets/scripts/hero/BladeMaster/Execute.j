//! zinc
library Execute requires DamageSystem, AggroSystem {
    public constant integer BM_VALOUR_MAX = 17;

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
        real valour;

        static method inst(unit u, string trace) -> thistype {
            if (thistype.ht.exists(u)) {
                return thistype.ht[u];
            } else {
                // print("Unregistered Blademaster: " + trace);
                return 0;
            }
        }

        method flushValour() -> real {
            real ret = this.valour;
            this.valour = 0;
            NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_EXECUTE, BTNExecute0);
            return ret;
        }

        method getValour() -> real {
            return this.valour;
        }
        
        method increaseValour(integer n) {
            integer show;
            string path;
            this.valour += n * (1.0 + ItemExAttributes.getUnitAttrVal(this.u, IATTR_BM_VALOR, SCOPE_PREFIX));
            if (this.valour > BM_VALOUR_MAX) {
                this.valour = BM_VALOUR_MAX;
            }
            show = (Rounding(this.valour) + 3) / 4;
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
            } else {
                path = BTNCleavingAttack;
            }
            NFSetPlayerAbilityIcon(GetOwningPlayer(this.u), SID_EXECUTE, path);
        }
    
        private static method increaseValourExe() {
            thistype this = GetTimerData(GetExpiredTimer());
            real timeout = returnTimerInterval(GetUnitAbilityLevel(this.u, SID_EXECUTE));
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
            this.flushValour();
            thistype.ht[u] = this;
            TimerStart(this.tm, returnTimerInterval(GetUnitAbilityLevel(u, SID_EXECUTE)), true, function thistype.increaseValourExe);
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
        lvl = GetUnitAbilityLevel(DamageResult.source, SID_EXECUTE);
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
        real v = ValourManager.inst(SpellEvent.CastingUnit, "onCast").flushValour();
        real dmg = v * returnDamagePerPoint(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EXECUTE)) + (UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * v * 0.1);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_EXECUTE, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE, true);
        AddTimedEffect.atUnit(ART_GORE, SpellEvent.TargetUnit, "origin", 0.3);
    }

    public function GetUnitValour(unit u) -> real {
        ValourManager vm = ValourManager.inst(u, "GetValour");
        if (vm != 0) {
            return vm.getValour();
        } else {
            return 0.0;
        }
    }

    function level() -> boolean {
        unit u;
        integer lvl;
        if (GetLearnedSkill() == SID_EXECUTE) {
            u = GetTriggerUnit();
            lvl = GetUnitAbilityLevel(u, SID_EXECUTE);
            if (lvl == 1) {
                ValourManager.start(u);
            }
        }
        u = null;
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);
        RegisterDamagedEvent(damaged);
        RegisterSpellEffectResponse(SID_EXECUTE, onCast);
    }
}
//! endzinc
