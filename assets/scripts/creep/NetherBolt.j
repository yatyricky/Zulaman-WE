//! zinc
library NetherBolt requires CastingBar, Projectile, SpellReflection {

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, p.r0, SpellData.inst(SID_NETHER_BOLT, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
            return true;
        }
    }

    function onCast() {
        Projectile p = Projectile.create();
        real amt;
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = ART_ANNIHILATION_MISSILE;
        p.pr = onhit;
        p.speed = 600;
        p.r0 = 1000.0;
        p.launch();

        amt = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * 0.2;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt, SpellData.inst(SID_NETHER_BOLT, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_NETHER_BOLT, onCast);
    }
}
//! endzinc
