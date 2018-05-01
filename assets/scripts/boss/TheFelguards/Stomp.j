//! zinc
library Stomp requires DamageSystem {

    function onCast() {
        integer i;
        for (0 <= i < PlayerUnits.n) {
            if (GetDistance.units(SpellEvent.CastingUnit, PlayerUnits.units[i]) <= 500.0) {
               DamageTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], 1500.0, SpellData[SID_STOMP].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
               StunUnit(SpellEvent.CastingUnit, PlayerUnits.units[i], 2.0);
            }
        }

        AddTimedEffect.atCoord(ART_STOMP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 0.1);
    }

    function onInit() {
       RegisterSpellEffectResponse(SID_STOMP, onCast);
    }
}
//! endzinc
