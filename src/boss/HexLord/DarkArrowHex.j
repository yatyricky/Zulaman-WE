//! zinc
library DarkArrowHex requires SpellEvent, DamageSystem, Projectile {
#define PATH "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, 200.0, SpellData[SIDDARKARROWHEX].name, true, true, false, WEAPON_TYPE_WHOKNOWS);
        return true;
    }

    function onCast() {
        Projectile p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = PATH;
        p.pr = onhit;
        p.speed = 900;
        p.launch();
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDARKARROWHEX, onCast);
    }
   
#undef PATH
}
//! endzinc
