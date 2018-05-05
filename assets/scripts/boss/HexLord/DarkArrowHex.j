//! zinc
library DarkArrowHex requires SpellEvent, DamageSystem, Projectile {
constant string  PATH  = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl";

    function onhit(Projectile p) -> boolean {
        DamageTarget(p.caster, p.target, 200.0, SpellData.inst(SID_DARK_ARROW_HEX, SCOPE_PREFIX).name, true, true, false, WEAPON_TYPE_WHOKNOWS);
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
        RegisterSpellEffectResponse(SID_DARK_ARROW_HEX, onCast);
    }
   

}
//! endzinc
