//! zinc
library HealTester requires SpellEvent {

    function onCast() {        
        SetWidgetLife(SpellEvent.CastingUnit, 1);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEAL_TESTER, onCast);
    }
}
//! endzinc
