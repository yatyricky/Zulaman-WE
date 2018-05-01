//! zinc
library HealScroll requires SpellEvent, DamageSystem {

    function onCast() {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= 950.0 && !IsUnitDead(PlayerUnits.units[i])) {
                HealTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], 750.0, SpellData[SID_HEAL_SCROLL].name, 0.0);
                AddTimedEffect.atUnit(ART_HEAL, PlayerUnits.units[i], "origin", 0.2);
            }
            i += 1;
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEAL_SCROLL, onCast);
        
    }
}
//! endzinc
