//! zinc
library FastHeal requires DamageSystem {

    function response(CastingBar cd) {
        HealTarget(cd.caster, cd.target, 5000.0, SpellData.inst(SID_FAST_HEAL, SCOPE_PREFIX).name, 0.0, true);
        AddTimedEffect.atUnit(ART_HEAL, cd.target, "origin", 0.2);
    }
    
    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FAERIE_DRAGON_MISSILE).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FAST_HEAL, onChannel);
    }

}
//! endzinc
