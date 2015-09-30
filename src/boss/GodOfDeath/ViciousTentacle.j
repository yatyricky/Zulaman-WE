//! zinc
library ViciousTentacle {
#define ART_MISSILE "Abilities\\Weapons\\LichMissile\\LichMissile.mdl"
#define ART_EFFECT "zxzccx"

    function onEffect(Buff buf) {
        StunUnit(buf.bd.caster, buf.bd.target, 2.0);
        AddTimedEffect.atUnit(ART_EFFECT, buf.bd.target, "origin", 0.5);
    }

    function onRemove(Buff buf) {}

    function onhit(Projectile p) -> boolean {
        Buff buf;
        if (TryReflect(p.target)) {
            p.reverse();
            return false;
        } else {
	        buf = Buff.cast(p.caster, p.target, BID);
	        buf.bd.interval = 3.0;
	        buf.bd.tick = 3;
	        buf.bd.boe = onEffect;
	        buf.bd.bor = onRemove;
	        buf.run();
            return true;
        }
    }

	function onCast() {
        Projectile p = Projectile.create();
        p.caster = SpellEvent.CastingUnit;
        p.target = SpellEvent.TargetUnit;
        p.path = ART_MISSILE;
        p.pr = onhit;
        p.speed = 500;
        p.launch();
	}

	function onInit() {
        BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID, onCast);
	}
#undef ART_EFFECT
#undef ART_MISSILE
}
//! endzinc
