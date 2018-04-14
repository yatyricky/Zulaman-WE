//! zinc
library UnholyFrenzy requires UnitProperty {
/*
Increase attack speed by 100%.
Duration 6 seconds
Magical positive effect
*/
constant string  ART  = "Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl";
constant real DURATION = 8.0;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_UNHOLY_FRENZY);
        buf.bd.tick = -1;
        buf.bd.interval = DURATION;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 100;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_UNHOLY_FRENZY, onCast);
        BuffType.register(BID_UNHOLY_FRENZY, BUFF_MAGE, BUFF_POS);
    }


}
//! endzinc
