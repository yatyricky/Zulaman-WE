//! zinc
library ClusterRockets requires CastingBar, Projectile {
#define ART_MISSILE "Abilities\\Spells\\Other\\TinkerRocket\\TinkerRocketMissile.mdl"

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, 450, SpellData[SID_CLUSTER_ROCKETS].name, false, true, false, WEAPON_TYPE_WHOKNOWS);   
        return true;
    }

    function response(CastingBar cd) {
        Projectile p;
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (!IsUnitDead(PlayerUnits.units[i]) && !IsUnitDummy(PlayerUnits.units[i])) {
                p = Projectile.create();
                p.caster = cd.caster;
                p.target = PlayerUnits.units[i];
                p.path = ART_MISSILE;
                p.pr = onhit;
                p.speed = 700;
                p.launch();
            }
            i += 1;
        }
    }
    
    function onChannel() {
        CastingBar.create(response).launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_CLUSTER_ROCKETS, onChannel);
    }
#undef ART_MISSILE
}
//! endzinc
