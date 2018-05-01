//! zinc
library RageStrike {

    function ruleHighestHPInrange(unit u1, unit u2) -> boolean {
        real r1 = GetDistance.units2d(SpellEvent.CastingUnit, u1);
        real r2 = GetDistance.units2d(SpellEvent.CastingUnit, u2);
        real lp1, lp2;
        if (r1 <= 256 && r2 <= 256) {
            lp1 = GetWidgetLife(u1) / GetUnitState(u1, UNIT_STATE_MAX_LIFE);
            lp2 = GetWidgetLife(u2) / GetUnitState(u2, UNIT_STATE_MAX_LIFE);
            return lp2 < lp1;
        } else {
            return r1 < r2;
        }
    }

    function onCast() {
        UnitListSortRule ulsr = ruleHighestHPInrange;
        PlayerUnits.sortByRule(ulsr);
        DamageTarget(SpellEvent.CastingUnit, PlayerUnits.sorted[0], 1000.0, SpellData[SID_RAGE_STRIKE].name, true, true, true, WEAPON_TYPE_WHOKNOWS);
        // TODO Play some effects
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_RAGE_STRIKE, onCast);
    }
}
//! endzinc
