//! zinc
library FireBall {
/*
AOE fire balls, deals 600 damage to all targets

*/
#define PATH
    function onhit(Projectile p) -> boolean {
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
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
	        p.speed = 700;
	        p.r0 = 600.0;
	        //BJDebugMsg("1??");
	        p.launch();
        }
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID, onChannel);
    }
#undef PATH
}
//! endzinc
