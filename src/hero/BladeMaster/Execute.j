//! zinc
library Execute requires BladeMasterGlobal, DamageSystem, AggroSystem {
    function returnTimerInterval(integer lvl) -> real {
        return 6.0 - lvl;
    }
    
    function returnDamagePerPoint(integer lvl) -> real {
        return 40.0;
    }
    
    function returnManaRegen(integer lvl) -> real {
        return 2.0 + lvl;
    }

    integer continuous[NUMBER_OF_MAX_PLAYERS];
    
    function damaged() {
        integer id;
        integer lvl;
        real mana;
        if (GetUnitAbilityLevel(DamageResult.source, SIDEXECUTELEARN) > 0) {
            lvl = GetUnitAbilityLevel(DamageResult.source, SIDEXECUTELEARN);
            mana = returnManaRegen(lvl);
            if (DamageResult.abilityName == DAMAGE_NAME_MELEE || DamageResult.abilityName == SpellData[SIDMORTALSTRIKE].name || DamageResult.abilityName == SpellData[SIDHEROICSTRIKE].name) {
                id = GetPlayerId(GetOwningPlayer(DamageResult.source));
                if (continuous[id] == 1) {                  
                    if (DamageResult.isCritical) {
                        IncreaseValour(DamageResult.source, continuous[id]);  
                        ModUnitMana(DamageResult.source, mana);
                        continuous[id] *= 2;
                    }
                } else {
                    if (DamageResult.isCritical) {
                        IncreaseValour(DamageResult.source, continuous[id]);  
                        ModUnitMana(DamageResult.source, mana);
                        continuous[id] *= 2;
                    } else {
                        continuous[id] = 1;
                    }
                }
            }
        }
    }
    
    function onCast() {
        integer v = GetAllVlour(SpellEvent.CastingUnit);
        real dmg = v * returnDamagePerPoint(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDEXECUTELEARN)) + (UnitProp[SpellEvent.CastingUnit].AttackPower() * v * 0.1);
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDEXECUTELEARN].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
        AddTimedEffect.atUnit(ART_GORE, SpellEvent.TargetUnit, "origin", 0.3);
    }
    
    struct AutoIncreaseValour {
        private timer tm;
        private unit u;
    
        private static method increaseValourExe() {
            thistype this = GetTimerData(GetExpiredTimer());
            real timeout = returnTimerInterval(GetUnitAbilityLevel(this.u, SIDEXECUTELEARN));
            if (IsInCombat()) {
                IncreaseValour(this.u, 1);
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
            TimerStart(this.tm, returnTimerInterval(GetUnitAbilityLevel(u, SIDEXECUTELEARN)), true, function thistype.increaseValourExe);
        }
    
    }

    function level() -> boolean {
        player p;
        unit u;
        integer i, j;
        if (GetLearnedSkill() == SIDEXECUTELEARN) {
            u = GetTriggerUnit();
            i = GetUnitAbilityLevel(u, SIDEXECUTELEARN);
            if (i == 1) {
                p = GetOwningPlayer(u);
                SetPlayerAbilityAvailable(p, SIDEXECUTESTART, true);
                
                AutoIncreaseValour.start(u);
                //GroupAddUnit(increaseValour, u);
            } else {
                j = SIDEXECUTESTART;
                while (j <= SIDEXECUTEEND) {
                    SetUnitAbilityLevel(u, j, i);
                    j += 1;
                }
            } 
        }
        u = null;
        p = null;
        return false;
    }
    
    function registerentered(unit u) {       
        player p = null;
		integer i;
        if (GetUnitTypeId(u) == UTIDBLADEMASTER) {
            p = GetOwningPlayer(u);
            i = SIDEXECUTESTART;
            while (i <= SIDEXECUTEEND) {
                SetPlayerAbilityAvailable(p, i, false);
                i += 1;
            }
            p = null;
        }
    }

    function onInit() {
        integer j;
        //increaseValour = NewGroup(); // forgotten algorithm
        //GroupRefresh(increaseValour);
        //TimerStart(NewTimer(), INTERVAL, true, function IncreaseValourRun); // auto increase valour
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);            // learnt
        RegisterDamagedEvent(damaged);            // detect critical
        RegisterUnitEnterMap(registerentered);    // initial register
        
        j = SIDEXECUTESTART;
        while (j <= SIDEXECUTEEND) {
            RegisterSpellEffectResponse(j, onCast);
            j += 1;
        }        
        
        j = 0;
        while (j < NUMBER_OF_MAX_PLAYERS) {
            continuous[j] = 1;
            j += 1;
        }
    }
}
//! endzinc
