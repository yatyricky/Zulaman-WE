//! zinc
library ManaScroll requires SpellEvent, ZAMCore {

    function onCast() {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 900.0 && !IsUnitDead(PlayerUnits.units[i])) {
                ModUnitMana(PlayerUnits.units[i], GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_MANA) * 0.3);
                AddTimedEffect.atUnit(ART_MANA, PlayerUnits.units[i], "origin", 0.2);
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_SCROLL, onCast);
        
    }
}
//! endzinc
