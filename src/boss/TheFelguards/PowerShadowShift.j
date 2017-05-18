//! zinc
library PowerShadowShift {

    function response(CastingBar cd) {
        real amt = GetUnitState(cd.target, UNIT_STATE_MAX_lIFE) * 0.5;
        DamageTarget(cd.caster, cd.target, amt, SpellData[SID_POWER_SHADOW_SHIFT].name, false, false, false, WEAPON_TYPE_WHOKNOWS);   
        HealTarget(cd.caster, cd.caster, amt * 50.0, SpellData[SID_POWER_SHADOW_SHIFT].name, 0.0);
    }

    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_POWER_SHADOW_SHIFT, onChannel);
    }

}
//! endzinc
 