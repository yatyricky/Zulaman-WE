//! zinc
library ChargedBreath requires SpellEvent, DamageSystem {

    function returnRange() -> real {
        return 300.0 + 197.0;
    }
    
    function onCast() {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.units2d(PlayerUnits.units[i], SpellEvent.CastingUnit) <= returnRange() && !IsUnitDead(PlayerUnits.units[i])) {                
                DamageTarget(SpellEvent.CastingUnit, PlayerUnits.units[i], GetUnitMana(SpellEvent.CastingUnit), SpellData.inst(SID_CHARGED_BREATH, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                AddTimedLight.atUnits("CLPB", SpellEvent.CastingUnit, PlayerUnits.units[i], 0.3);
                AddTimedEffect.atUnit(ART_IMPACT, PlayerUnits.units[i], "origin", 1.0);
            }
            i += 1;
        }
        SetUnitManaBJ(SpellEvent.CastingUnit, 0.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CHARGED_BREATH, onCast);
    }

}
//! endzinc
