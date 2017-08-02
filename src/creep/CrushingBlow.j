//! zinc
library CrushingBlow requires DamageSystem {

    function response(CastingBar cd) {
        DamageTarget(cd.caster, cd.target, GetUnitState(cd.caster, UNIT_STATE_MAX_LIFE) * 0.7, SpellData[SID_CRUSHING_BLOW].name, true, false, true, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_STOMP, cd.target, "origin", 0.1);
    }

    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_CRUSHING_BLOW, onChannel);
    }
}
//! endzinc
