//! zinc
library ShieldHex requires BuffSystem, SpellEvent {
#define BUFF_ID 'A01I'

    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
		buf.bd.tick = -1;
		buf.bd.interval = 10.0;
		buf.bd.isShield = true;
		buf.bd.r0 = 5000.0;
		if (buf.bd.e0 == 0) {
			buf.bd.e0 = BuffEffect.create(ART_SHIELD, buf, "overhead");
		}
		buf.bd.boe = onEffect;
		buf.bd.bor = onRemove;
		buf.run();
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SIDSHIELDHEX, onCast);
    }
#undef BUFF_ID
}
//! endzinc
