//! zinc
library WELA requires CastingBar, ModelInfo, SpellData, AggroSystem {
    private string sessionName;
    private boolean combatState = false;

    private string wela[];
    private integer welaI = 0;
    private integer welaN = 0;
    
    public function GenerateCombatLog(string name) {
        integer i;
        string filePath;
        if (name == null || name == "") {
            name = "Auto";
        }
        filePath = sessionName + "-" + I2S(welaN) + "-" + name + ".wela";
        // print("WELA generate, Name = "+name+", size = "+I2S(welaI)+", path = "+filePath);
        PreloadGenClear();
        PreloadGenStart();
        for (0 <= i < welaI) {
            Preload(wela[i]);
        }
        PreloadGenEnd(filePath);
        welaI = 0;
        welaN += 1;
    }

    function damageRecord() {
        wela[welaI] = "damage," /*
        */ + R2S(GetGameTime()) + "," /*
        */ + GetUnitNameEx(DamageResult.source) + "," /*
        */ + GetUnitNameEx(DamageResult.target) + "," /*
        */ + DamageResult.abilityName + "," /*
        */ + R2S(DamageResult.amount) + "," /*
        */ + B2S(DamageResult.isHit) + "," /*
        */ + B2S(DamageResult.isBlocked) + "," /*
        */ + B2S(DamageResult.isDodged) + "," /*
        */ + B2S(DamageResult.isCritical) + "," /*
        */ + B2S(DamageResult.isImmune) + "," /*
        */ + B2S(DamageResult.isPhyx) + "," /*
        */ + B2S(DamageResult.wasDodgable) + "," /*
        */ + ModelInfo.get(GetUnitTypeId(DamageResult.source), "WELA: 101").Career() + "," /*
        */ + ModelInfo.get(GetUnitTypeId(DamageResult.target), "WELA: 102").Career();
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function healedRecord() {
        wela[welaI] = "heal," /*
        */ + R2S(GetGameTime()) + "," /*
        */ + GetUnitNameEx(HealResult.source) + "," /*
        */ + GetUnitNameEx(HealResult.target) + "," /*
        */ + HealResult.abilityName + "," /*
        */ + R2S(HealResult.effective) + "," /*
        */ + R2S(HealResult.amount - HealResult.effective) + "," /*
        */ + B2S(HealResult.isCritical) + "," /*
        */ + ModelInfo.get(GetUnitTypeId(HealResult.source), "InfoBoards: 606").Career() + "," /*
        */ + ModelInfo.get(GetUnitTypeId(HealResult.target), "InfoBoards: 607").Career();
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function absorbRecord() {
        wela[welaI] = "heal," /*
        */ + R2S(GetGameTime()) + "," /*
        */ + GetUnitNameEx(AbsorbResult.source) + "," /*
        */ + GetUnitNameEx(AbsorbResult.target) + "," /*
        */ + AbsorbResult.abilityName + "," /*
        */ + R2S(AbsorbResult.amount) + "," /*
        */ + R2S(0.0) + "," /*
        */ + B2S(false) + "," /*
        */ + ModelInfo.get(GetUnitTypeId(AbsorbResult.source), "InfoBoards: 606").Career() + "," /*
        */ + ModelInfo.get(GetUnitTypeId(AbsorbResult.target), "InfoBoards: 607").Career();
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function combatStatusLog() {
        combatState = !combatState;
        wela[welaI] = "combat," + R2S(GetGameTime());
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function castLog() {
        if (IsLastSpellSuccess(SpellEvent.CastingUnit)) {
            wela[welaI] = "cast," /*
            */ + R2S(GetGameTime()) + "," /*
            */ + GetUnitNameEx(SpellEvent.CastingUnit) + "," /*
            */ + GetUnitNameEx(SpellEvent.TargetUnit) + "," /*
            */ + SpellData[SpellEvent.AbilityId].name;
            welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
        }
    }

    function manaLog() {
        integer i;
        if (combatState) {
            for (0 <= i < PlayerUnits.n) {
                if (!IsUnitDead(PlayerUnits.units[i]) && IsUnitType(PlayerUnits.units[i], UNIT_TYPE_HERO)) {
                    wela[welaI] = "mana," /*
                    */ + R2S(GetGameTime()) + "," /*
                    */ + GetUnitNameEx(PlayerUnits.units[i]) + "," /*
                    */ + R2S(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MANA)) + "," /*
                    */ + R2S(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_MANA));
                    welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
                }
            }
        }
    }

    private function onInit() {
        sessionName = I2HEX(GetRandomInt(0, 0x7FFFFFFF));
        TimerStart(CreateTimer(), 0.1, false, function() {
            DestroyTimer(GetExpiredTimer());

            // World Editor Log Analyser
            RegisterHealedEvent(healedRecord);
            RegisterDamagedEvent(damageRecord);
            RegisterAbsorbedEvent(absorbRecord);
            RegisterCombatStateNotify(combatStatusLog);
            RegisterSpellEndCastResponse(0, castLog);
            TimerStart(CreateTimer(), 1.0, true, function manaLog);
        });
    }
}
//! endzinc
