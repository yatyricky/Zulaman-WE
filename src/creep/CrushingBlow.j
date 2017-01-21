//! zinc
library CrushingBlow requires SpellEvent, ZAMCore {

    function response(CastingBar cd) {
        DamageTarget(cd.caster, cd.target, GetUnitState(cd.caster, UNIT_STATE_MAX_LIFE) * 0.7, SpellData[SID_CRUSHING_BLOW].name, true, true, true, WEAPON_TYPE_WHOKNOWS);   
    }

    function onCast() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_CRUSHING_BLOW, onCast);
    }
}
//! endzinc
