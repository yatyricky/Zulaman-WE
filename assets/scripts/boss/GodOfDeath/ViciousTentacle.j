//! zinc
library ViciousTentacle requires BuffSystem {

    function onEffect(Buff buf) {
        StunUnit(buf.bd.caster, buf.bd.target, 2.0);
        AddTimedEffect.atUnit(ART_SOUL_THEFT_EFFECT, buf.bd.target, "origin", 0.5);
    }

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
            buf = Buff.cast(p.caster, p.target, BID_VICIOUS_TENTACLE_STUN);
            buf.bd.interval = 3.0;
            buf.bd.tick = 3;
            buf.bd.boe = onEffect;
            buf.bd.bor = Buff.noEffect;
            buf.run();
            return true;
        }
    }

    function onCast() {
        Projectile p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = ART_DruidoftheTalonMissile;
        p.pr = onhit;
        p.speed = 500;
        p.launch();
    }

    function onInit() {
        BuffType.register(BID_VICIOUS_TENTACLE_STUN, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_VICIOUS_TENTACLE_STUN, onCast);
    }

}
//! endzinc
