//! zinc
library FireBolt requires DamageSystem {

    function onHit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_FIRE_BOLT, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p = Projectile.create();
        p.caster = cd.caster;
        p.target = PlayerUnits.getRandomHero();
        p.path = ART_FireBallMissile;
        p.pr = onHit;
        p.speed = 1200;
        p.r0 = 500.0;
        p.launch();
    }

    function onChannel() {
        CastingBar.create(response).setVisuals(ART_FireBallMissile).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FIRE_BOLT, onChannel);
    }

}
//! endzinc
