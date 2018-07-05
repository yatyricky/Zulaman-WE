//! zinc
library MindBlast requires GodOfDeathGlobal, Projectile {

    function onLanding(Projectile p) -> boolean {
        integer i = 0;
        while (i < PlayerUnits.n) {
            if (GetDistance.unitCoord(PlayerUnits.units[i], p.targetX, p.targetY) <= GodOfDeathGlobalConst.mindBlastAOE) {
                DamageTarget(p.caster, PlayerUnits.units[i], 1000.0, SpellData.inst(SID_MIND_BLAST, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS, false);
                ModUnitMana(p.caster, 10);
            }
            i += 1;
        }
        return true;
    }

    function onCast() {
        Projectile p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.targetX = SpellEvent.TargetX;
        p.targetY = SpellEvent.TargetY;
        p.targetZ = GetLocZ(p.targetX, p.targetY);
        p.path = ART_ANNIHILATION_MISSILE;
        p.pr = onLanding;
        p.speed = 400.0;
        p.scale = 2.0;
        p.spill(300.0);
        VisualEffects.circle(ART_GlowingRunes7, SpellEvent.TargetX, SpellEvent.TargetY, GodOfDeathGlobalConst.mindBlastAOE, 15, 2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MIND_BLAST, onCast);
    }

}
//! endzinc
