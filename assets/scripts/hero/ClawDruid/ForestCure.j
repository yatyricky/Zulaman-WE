//! zinc
library ForestCure requires SpellEvent, UnitProperty, DamageSystem {

    function returnPercent(integer lvl) -> real {
        return 0.03 * lvl;
    }

    function returnPoints(integer lvl) -> real {
        if (lvl == 1) {
            return 60.0;
        } else if (lvl == 2) {
            return 120.0;
        } else {
            return 240.0;
        }
    }

    function onCast() {
        real cost = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MANA) / GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA);
        real amt;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FOREST_CURE);
        if (cost > 0.5) {
            cost = 0.5;
        }
        ModUnitMana(SpellEvent.CastingUnit, 0.0 - GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA) * cost);
        amt = (returnPercent(lvl) * GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) + returnPoints(lvl)) * (cost / 0.5);
        
        UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).aggroRate += 3.0;
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt, SpellData.inst(SID_FOREST_CURE, SCOPE_PREFIX).name, -3.0, false);
        UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).aggroRate -= 3.0;
        AddTimedEffect.atUnit(ART_Owl, SpellEvent.CastingUnit, "overhead", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FOREST_CURE, onCast);
    }

}
//! endzinc
