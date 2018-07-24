//! zinc
library FireBall requires DamageSystem {

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_FIRE_BALL, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p;
        integer i;
        for (0 <= i < PlayerUnits.n) {
            p = Projectile.create();
            p.caster = cd.caster;
            p.target = PlayerUnits.units[i];
            p.path = ART_FireBallMissile;
            p.pr = onhit;
            p.speed = 900;
            p.r0 = 500.0;
            p.launch();
        }
    }
    
    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FireBallMissile).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FIRE_BALL, onChannel);
    }

}
//! endzinc
