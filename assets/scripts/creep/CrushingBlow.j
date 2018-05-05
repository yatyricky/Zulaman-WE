//! zinc
library CrushingBlow requires DamageSystem {

    function response(CastingBar cd) {
        DamageTarget(cd.caster, cd.target, GetUnitState(cd.target, UNIT_STATE_MAX_LIFE) * 0.7, SpellData.inst(SID_CRUSHING_BLOW, SCOPE_PREFIX).name, true, false, true, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_THUNDER_CLAPCASTER, cd.target, "origin", 0.1);
    }

    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_CRUSHING_BLOW, onChannel);
    }
}
//! endzinc
