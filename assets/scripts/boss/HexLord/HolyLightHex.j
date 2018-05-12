//! zinc
library HolyLightHex requires CastingBar {
    function response(CastingBar cd) {
        HealTarget(cd.caster, cd.target, 15000.0, SpellData.inst(SID_HOLY_BOLT_HEX, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_RESURRECT_TARGET, cd.target, "origin", 0.2);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_HOLY_BOLT_HEX, onChannel);
    }
}
//! endzinc
