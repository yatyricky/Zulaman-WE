//! zinc
library ShadowSpike {
/*
deals 400 magical damage to target.
then deals 200 + x magical damage to target where x equals to target HP lost times 0.33 per second.
duration 10 seconds
magical negative effect
*/
    function onEffect(Buff buf) {
    	real amt = 200 + GetUnitLifeLost(buf.bd.target) * 0.33;
        DamageTarget(buf.bd.caster, buf.bd.target, amt, SpellData[SID].name, false, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

	function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnipt, SpellEvent.TargetUnit, BID);
        buf.bd.tick = 10;
        buf.bd.interval = 1;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
	}

	function onInit() {
		RegisterSpellEffectResponse(SID, onCast);
		BuffType.register(BID, BUFF_MAGE, BUFF_NEG);
	}
}
//! endzinc
 