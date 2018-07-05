//! zinc
library UnholyTentacle requires SpellEvent {
    
    function onCast() {
        real angle = GetRandomReal(0.001, bj_PI * 2);
        CreateUnit(Player(MOB_PID), UTID_UNHOLY_TENTACLE, GetUnitX(GetTriggerUnit()) + Cos(angle) * 520.0, GetUnitY(GetTriggerUnit()) + Sin(angle) * 520.0, 0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SUMMON_UNHOLY_TENTACLES, onCast);
    }
}
//! endzinc
