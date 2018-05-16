//! zinc
library WELA requires CastingBar, SpellData, AggroSystem {
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
        filePath = sessionName + "-" + I2S(welaN) + "-" + name + ".pld";
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

    function combatStatusLog() {
        combatState = !combatState;
        wela[welaI] = R2S(GetGameTime()) + "|combat";
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function damageRecord() {
        wela[welaI] = R2S(GetGameTime()) /*
        2  */ + "|damage|" /*
        3  */ + GetUnitNameEx(DamageResult.source) + "|" /*
        4  */ + ModelInfo.get(GetUnitTypeId(DamageResult.source), "WELA D1").Career() + "|" /*
        5  */ + GetUnitNameEx(DamageResult.target) + "|" /*
        6  */ + ModelInfo.get(GetUnitTypeId(DamageResult.target), "WELA D2").Career() + "|" /*
        7  */ + DamageResult.abilityName + "|" /*
        8  */ + R2S(DamageResult.amount);
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function healedRecord() {
        wela[welaI] = R2S(GetGameTime()) /*
        2  */ + "|heal|" /*
        3  */ + GetUnitNameEx(HealResult.source) + "|" /*
        4  */ + ModelInfo.get(GetUnitTypeId(HealResult.source), "WELA H1").Career() + "|" /*
        5  */ + GetUnitNameEx(HealResult.target) + "|" /*
        6  */ + ModelInfo.get(GetUnitTypeId(HealResult.target), "WELA H2").Career() + "|" /*
        7  */ + HealResult.abilityName + "|" /*
        8  */ + R2S(HealResult.effective) + "|" /*
        9  */ + R2S(HealResult.amount - HealResult.effective);
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function absorbRecord() {
        wela[welaI] = R2S(GetGameTime()) /*
        2  */ + "|heal|" /*
        3  */ + GetUnitNameEx(AbsorbResult.source) + "|" /*
        4  */ + ModelInfo.get(GetUnitTypeId(AbsorbResult.source), "WELA A1").Career() + "|" /*
        5  */ + GetUnitNameEx(AbsorbResult.target) + "|" /*
        6  */ + ModelInfo.get(GetUnitTypeId(AbsorbResult.target), "WELA A2").Career() + "|" /*
        7  */ + AbsorbResult.abilityName + "|" /*
        8- */ + R2S(AbsorbResult.amount) + "|0.0";
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function castLog() {
        integer tutid;
        if (IsLastSpellSuccess(SpellEvent.CastingUnit) && IsUnitDummy(SpellEvent.CastingUnit) == false) {
            tutid = GetUnitTypeId(SpellEvent.TargetUnit);
            if (tutid == 0) {tutid = UTID_DAMAGE_DUMMY;}
            wela[welaI] = R2S(GetGameTime()) /*
        2  */ + "|cast|" /*
        3  */ + GetUnitNameEx(SpellEvent.CastingUnit) + "|" /*
        4  */ + ModelInfo.get(GetUnitTypeId(SpellEvent.CastingUnit), "WELA C1").Career() + "|" /*
        5  */ + GetUnitNameEx(SpellEvent.TargetUnit) + "|" /*
        6  */ + ModelInfo.get(tutid, "WELA C2").Career() + "|" /*
        7  */ + SpellData.inst(SpellEvent.AbilityId, SCOPE_PREFIX).name;
            welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
        }
    }

    function manaLog() {
        integer i;
        if (combatState) {
            for (0 <= i < PlayerUnits.n) {
                if (!IsUnitDead(PlayerUnits.units[i]) && IsUnitType(PlayerUnits.units[i], UNIT_TYPE_HERO)) {
                    wela[welaI] = R2S(GetGameTime()) /*
                    */ + "|mana|" /*
                    */ + GetUnitNameEx(PlayerUnits.units[i]) + "|" /*
                    */ + R2S(GetUnitState(PlayerUnits.units[i], UNIT_STATE_MANA)) + "|" /*
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
