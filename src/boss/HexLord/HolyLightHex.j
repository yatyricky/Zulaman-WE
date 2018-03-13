//! zinc
library HolyLightHex requires CastingBar {
    function response(CastingBar cd) {
        HealTarget(cd.caster, cd.target, 15000.0, SpellData[SID_HOLY_BOLT_HEX].name, 0.0);
        AddTimedEffect.atUnit(ART_HOLY_LIGHT, cd.target, "origin", 0.2);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_HOLY_BOLT_HEX, onChannel);
    }
}
//! endzinc
