//! zinc
library HolyLightHex requires CastingBar {
	function response(CastingBar cd) {
        HealTarget(cd.caster, cd.target, 15000.0, SpellData[SIDHOLYBOLTHEX].name, 0.0);
        AddTimedEffect.atUnit(ART_HOLY_LIGHT, cd.target, "origin", 0.2);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDHOLYBOLTHEX, onChannel);
    }
}
//! endzinc
