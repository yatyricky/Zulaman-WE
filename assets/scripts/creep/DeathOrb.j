//! zinc
library DeathOrb requires DamageSystem, Projectile {

    function hurlOrb(unit from, unit to, unit caster, integer count) {
        Projectile p = Projectile.create();
        p.caster = from;
        p.target = to;
        p.path = ART_DEATH_COIL_MISSILE;
        p.pr = onhit;
        p.speed = 500;
        p.r0 = 600;
        p.u0 = caster;
        p.i0 = count;
        p.launch();
    }

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            p.u0 = p.caster;
            return false;
        } else {
            if (GetPidofu(p.u0) < NUMBER_OF_MAX_PLAYERS) {
                p.i0 = 0;
            }
            if (IsUnitEnemy(p.u0, GetOwningPlayer(p.target))) {
                DamageTarget(p.u0, p.target, p.r0, SpellData.inst(SID_DEATH_ORB, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, true);
                AddTimedEffect.atUnit(ART_DEATH_COIL_SPECIAL_ART, p.target, "origin", 0.2);
            }
            p.i0 -= 1;
            if (p.i0 > 0) {
                hurlOrb(p.target, PlayerUnits.getFarest(p.target), p.u0, p.i0);
            }
            return true;
        }
    }

    function response(CastingBar cd) {
        hurlOrb(cd.caster, cd.target, cd.caster, 3);
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_DEATH_ORB, onChannel);
    }

}
//! endzinc
