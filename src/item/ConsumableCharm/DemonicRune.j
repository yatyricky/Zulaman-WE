//! zinc
library DemonicRune requires SpellEvent, DamageSystem {
#define ART_TARGET "Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl"

    function onCast() {
        real amount = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * 0.2;
        real after = GetWidgetLife(SpellEvent.CastingUnit) - amount;
        if (after < 2.0) {after = 2.0;}
        SetWidgetLife(SpellEvent.CastingUnit, after);
        ModUnitMana(SpellEvent.CastingUnit, amount * 3.0);
        
        AddTimedEffect.atUnit(ART_TARGET, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DEMONIC_RUNE, onCast);
    }
#undef ART_TARGET
}
//! endzinc
