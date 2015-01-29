//! zinc
library ForestCure requires SpellEvent, UnitProperty, DamageSystem {
#define ART_CASTER "Units\\NightElf\\Owl\\Owl.mdl"

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
        // 不受强度加成，不会暴击        
        UnitProp[SpellEvent.CastingUnit].aggroRate += 3.0;
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt, SpellData[SID_FOREST_CURE].name, -3.0);
        UnitProp[SpellEvent.CastingUnit].aggroRate -= 3.0;
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "overhead", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FOREST_CURE, onCast);
    }
#undef ART_CASTER
}
//! endzinc
