//! zinc
library SelfDestruct requires SpellEvent, DamageSystem {
#define ART_EXPLOSION "Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl"

    function response(CastingBar cd) {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (!IsUnitDummy(PlayerUnits.units[i]) && !IsUnitDead(PlayerUnits.units[i]) && GetDistance.units2d(cd.caster, PlayerUnits.units[i]) < DBMArchTinker.selfDestructAOE) {
                DamageTarget(cd.caster, PlayerUnits.units[i], 300.0, SpellData[SID_SELF_DESTRUCT].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
            }
            i += 1;
        }
        AddTimedEffect.atCoord(ART_EXPLOSION, GetUnitX(cd.caster), GetUnitY(cd.caster), 0.3);
        KillUnit(cd.caster);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_SELF_DESTRUCT, onChannel);
    }
#undef ART_EXPLOSION
}
//! endzinc
