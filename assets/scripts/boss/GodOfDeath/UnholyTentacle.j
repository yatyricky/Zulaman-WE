//! zinc
library UnholyTentacle requires SpellEvent {
    
    function onCastUnholy() {
        real angle = GetRandomReal(0.001, bj_PI * 2);
        CreateUnit(Player(MOB_PID), UTID_UNHOLY_TENTACLE, GetUnitX(GetTriggerUnit()) + Cos(angle) * 520.0, GetUnitY(GetTriggerUnit()) + Sin(angle) * 520.0, 0);
    }
    
    function onCastFilthy() {
        real angle = GetRandomReal(0.001, bj_PI * 2);
        CreateUnit(Player(MOB_PID), UTID_FILTHY_TENTACLE, GetUnitX(GetTriggerUnit()) + Cos(angle) * 520.0, GetUnitY(GetTriggerUnit()) + Sin(angle) * 520.0, 0);
    }
    
    function onCastVicious() {
        real angle = GetRandomReal(0.001, bj_PI * 2);
        CreateUnit(Player(MOB_PID), UTID_VICIOUS_TENTACLE, GetUnitX(GetTriggerUnit()) + Cos(angle) * 520.0, GetUnitY(GetTriggerUnit()) + Sin(angle) * 520.0, 0);
    }
    
    function onCastFoul() {
        real angle = GetRandomReal(0.001, bj_PI * 2);
        CreateUnit(Player(MOB_PID), UTID_FOUL_TENTACLE, GetUnitX(GetTriggerUnit()) + Cos(angle) * 520.0, GetUnitY(GetTriggerUnit()) + Sin(angle) * 520.0, 0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_UNHOLY_TENTACLES, onCastUnholy);
        RegisterSpellEffectResponse(SID_SUMMON_FILTHY_TENTACLE, onCastFilthy);
        RegisterSpellEffectResponse(SID_SUMMON_VICIOUS_TENTACLE, onCastVicious);
        RegisterSpellEffectResponse(SID_SUMMON_FOUL_TENTACLE, onCastFoul);
    }
}
//! endzinc
