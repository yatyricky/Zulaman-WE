//! zinc
library ShieldOfSindoreiHex requires SpellEvent, BuffSystem {
#define BUFF_ID 'A031'
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 7.0;
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        buf.bd.r0 = 1.0;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_INVULNERABLE, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDSHIELDOFSINDOREIHEX, onCast);
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS); Already registered in original ability
    }
#undef BUFF_ID
}
//! endzinc
