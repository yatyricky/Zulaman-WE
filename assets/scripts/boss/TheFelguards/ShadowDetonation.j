//! zinc
library ShadowDetonation requires DamageSystem {

    function onCast() {

    }

    function onInit() {
        RegisterSpellCastResponse(SID_SHADOW_DETONATION, onCast);
    }

}
//! endzinc
