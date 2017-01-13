//! zinc
library Burning {

	function onEffect(Buff buf) {
		integer i;
		for (0 <= i < PlayerUnits.n) {
			if (GetDistance.units2d(buf.bd.caster, PlayerUnits.units[i]) <= 256) {
				DamageTarget(buf.bd.caster, PlayerUnits.units[i], 200.0, SpellData[SID_BURNING].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
			}
		}
	}

	function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_BURNING);
        buf.bd.interval = 1.0;
        buf.bd.tick = 10;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_BURNING, onCast);
        BuffType.register(BID_BURNING, BUFF_PHYX, BUFF_POS);
    }
}
//! endzinc
