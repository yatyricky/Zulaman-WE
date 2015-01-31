//! zinc
library AransCounterSpellScroll requires SpellEvent, CastingBar {
#define ART_CASTER "Abilities\\Spells\\Other\\Silence\\SilenceAreaBirth.mdl"
#define ART_TARGET "Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl"

    function onCast() {
        integer i = 0;
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 300.0 && !IsUnitDead(MobList.units[i])) {
                CounterSpell(MobList.units[i]);
                AddTimedEffect.atUnit(ART_TARGET, MobList.units[i], "overhead", 1.0);
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "overhead", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ARANS_COUNTER_SPELL_SCROLL, onCast);
    }
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
