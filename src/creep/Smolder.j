//! zinc
library Smolder requires DamageSystem {

    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData[SID_SMOLDER].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
            return true;
        }
    }

    function response(CastingBar cd) {
        Projectile p;
        integer i;
        for (0 <= i < PlayerUnits.n) {
            if (GetDistance.units(cd.caster, PlayerUnits.units[i]) <= 2000.0) {
                p = Projectile.create();
                p.caster = cd.caster;
                p.target = PlayerUnits.units[i];
                p.path = ART_BREATH_OF_FIRE_DAMAGE;
                p.pr = onhit;
                p.speed = 900;
                p.r0 = GetUnitState(PlayerUnits.units[i], UNIT_STATE_MAX_LIFE) * 0.02;
                p.launch();
            }
        }
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_SMOLDER, onChannel);
    }

}
//! endzinc
