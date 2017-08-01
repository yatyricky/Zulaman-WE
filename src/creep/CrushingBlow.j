//! zinc
library CrushingBlow requires DamageSystem {

    function response(CastingBar cd) {
        DamageTarget(cd.caster, cd.target, GetUnitState(cd.caster, UNIT_STATE_MAX_LIFE) * 0.7, SpellData[SID_CRUSHING_BLOW].name, true, true, true, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_STOMP, cd.target, "origin", 0.1);
    }

    function onCast() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CRUSHING_BLOW, onCast);
    }
}
//! endzinc
