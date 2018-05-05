//! zinc
library FrostBoltHex requires CastingBar, Projectile, SpellReflection {
constant string  ART_MISSILE  = "Abilities\\Weapons\\LichMissile\\LichMissile.mdl";

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, 400.0, SpellData.inst(SID_FROST_BOLT_HEX, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p = Projectile.create();
        p.caster = cd.caster;
        p.target = cd.target;
        p.path = ART_MISSILE;
        p.pr = onhit;
        p.speed = 700;
        p.launch();
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_FROST_BOLT_HEX, onChannel);
    }

}
//! endzinc
