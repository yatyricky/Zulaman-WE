//! zinc
library Gnaw requires CastingBar {

    function response(CastingBar cd) {
        // SetUnitAnimation(SpellEvent.CastingUnit, "Attack - 1");
        DamageTarget(cd.caster, cd.target, 300.0, SpellData[SID_GNAW].name, true, true, false, WEAPON_TYPE_WHOKNOWS);
        StunUnit(cd.caster, cd.target, 1.0);
        AddTimedEffect.atUnit(ART_BLEED, cd.target, "origin", 0.2);
    }
    
    function onChannel() {
        CastingBar.create(response).channel(5);
        StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 1.0);
    }
    
    function onInit() {
        RegisterSpellChannelResponse(SID_GNAW, onChannel);
    }
}
//! endzinc
