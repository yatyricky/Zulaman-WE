//! zinc
library SummonParasiticalRoach requires SpellEvent {

    function onCast() {
        Point p = GetUnitFrontPoint(SpellEvent.CastingUnit, 150.0);
        unit u = CreateUnit(Player(MOB_PID), UTID_PARASITICAL_ROACH, p.x, p.y, GetUnitFacing(SpellEvent.CastingUnit));
        AddTimedEffect.atUnit(ART_RAISE_SKELETON, u, "origin", 0.1);
        p.destroy();
        u = null;
    }

    function onInit() {
        RegisterSpellCastResponse(SID_SUMMON_PARASITICAL_ROACH, onCast);
    }

}
//! endzinc
