//! zinc
library FireBall requires DamageSystem {
constant string  PATH  = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl";
constant real DAMAGE = 500.0;

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData[SID_FIRE_BALL].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
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
            p.path = PATH;
            p.pr = onhit;
            p.speed = 900;
            p.r0 = DAMAGE;
            p.launch();
        }
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FIRE_BALL, onChannel);
    }


}
//! endzinc
