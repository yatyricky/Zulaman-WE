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
        4  */ + GetUnitNameEx(DamageResult.target) + "|" /*
        5  */ + DamageResult.abilityName + "|" /*
        6  */ + R2S(DamageResult.amount) + "|" /*
        7  */ + B2IS(DamageResult.isHit) + "|" /*
        8  */ + B2IS(DamageResult.isBlocked) + "|" /*
        9  */ + B2IS(DamageResult.isDodged) + "|" /*
        10 */ + B2IS(DamageResult.isCritical) + "|" /*
        11 */ + B2IS(DamageResult.isImmune) + "|" /*
        12 */ + B2IS(DamageResult.isPhyx) + "|" /*
        13 */ + B2IS(DamageResult.wasDodgable);
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function healedRecord() {
        wela[welaI] = R2S(GetGameTime()) /*
        2  */ + "|heal|" /*
        3  */ + GetUnitNameEx(HealResult.source) + "|" /*
        4  */ + GetUnitNameEx(HealResult.target) + "|" /*
        5  */ + HealResult.abilityName + "|" /*
        6  */ + R2S(HealResult.effective) + "|" /*
        7  */ + R2S(HealResult.amount - HealResult.effective) + "|" /*
        8  */ + B2IS(HealResult.isCritical);
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function absorbRecord() {
        wela[welaI] = R2S(GetGameTime()) /*
        2     */ + "|heal|" /*
        3     */ + GetUnitNameEx(AbsorbResult.source) + "|" /*
        4     */ + GetUnitNameEx(AbsorbResult.target) + "|" /*
        5     */ + AbsorbResult.abilityName + "|" /*
        6,7,8 */ + R2S(AbsorbResult.amount) + "|0.0|0";
        welaI += 1; if (welaI >= 8100) {GenerateCombatLog("AutoGen");}
    }

    function castLog() {
        if (IsLastSpellSuccess(SpellEvent.CastingUnit)) {
            wela[welaI] = R2S(GetGameTime()) /*
            */ + "|cast|" /*
            */ + GetUnitNameEx(SpellEvent.CastingUnit) + "|" /*
            */ + GetUnitNameEx(SpellEvent.TargetUnit) + "|" /*
            */ + SpellData[SpellEvent.AbilityId].name;
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
