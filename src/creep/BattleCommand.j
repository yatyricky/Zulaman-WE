//! zinc
library BattleCommand {
/*
target ally deals 100% more damage
duration 12 seconds
magic positive effect
*/
    function onEffect(Buff buf) { 
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID);
        buf.bd.tick = -1;
        buf.bd.interval = 12;
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        buf.bd.r0 = 1.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 0.1);
    }

    function onInit() {
        BuffType.register(BID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID, onCast);
    }
}
//! endzinc
