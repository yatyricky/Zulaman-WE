//! zinc
library SummonClockworkGoblin requires SpellEvent {

    function response(CastingBar cd) {
        real x = GetUnitX(cd.caster) - 100;
        real y = GetUnitY(cd.caster) - 100;
        CreateUnit(Player(MOB_PID), UTID_CLOCKWORK_GOBLIN, x, y, GetRandomReal(0, 360));
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_SUMMON_CLOCKWORK_GOBLIN, onChannel);
    }
}
//! endzinc
