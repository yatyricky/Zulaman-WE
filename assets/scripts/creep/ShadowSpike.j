//! zinc
library ShadowSpike requires DamageSystem {

    function onEffect(Buff buf) {
        real amt = 150.0 + GetUnitLifeLost(buf.bd.target) * 0.5;
        DamageTarget(buf.bd.caster, buf.bd.target, amt, SpellData.inst(SID_SHADOW_SPIKE, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            DamageTarget(p.caster, p.target, 500.0, SpellData.inst(SID_SHADOW_SPIKE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
            AddTimedEffect.atUnit(ART_SHADOW_STRIKE_TARGET, p.target, "origin", 0.2);

            buf = Buff.cast(p.caster, p.target, BID_SHADOW_SPIKE);
            buf.bd.tick = 6;
            buf.bd.interval = 2;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            return true;
        }
    }

    function onCast() {
        Projectile p = Projectile.create();
        real amt;
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = ART_SHADOW_STRIKE_MISSILE;
        p.pr = onhit;
        p.speed = 900;
        p.launch();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SHADOW_SPIKE, onCast);
        BuffType.register(BID_SHADOW_SPIKE, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
