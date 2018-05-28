//! zinc
library ShadowDetonation requires DamageSystem {

    function doEffect(DelayTask dt) {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i]) && GetDistance.unitCoord2d(PlayerUnits.units[i], dt.r0, dt.r1) < 300) {
                DamageTarget(dt.u0, PlayerUnits.units[i], 1500, SpellData.inst(SID_SHADOW_DETONATION, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
            }
            i += 1;
        }
        VisualEffects.nova(ART_ANNIHILATION_MISSILE, dt.r0, dt.r1, 300, 600, 18);
    }

    function onCast() {
        DelayTask dt;
        AddTimedEffect.atPos(ART_FLAME_STRIKE_TARGET, SpellEvent.TargetX, SpellEvent.TargetY, GetLocZ(SpellEvent.TargetX, SpellEvent.TargetY), 3.0, 1.0);
        dt = DelayTask.create(doEffect, 3.0);
        dt.u0 = SpellEvent.CastingUnit;
        dt.r0 = SpellEvent.TargetX;
        dt.r1 = SpellEvent.TargetY;
    }

    function onInit() {
        RegisterSpellCastResponse(SID_SHADOW_DETONATION, onCast);
    }

}
//! endzinc
