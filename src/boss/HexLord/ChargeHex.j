//! zinc
library ChargeHex requires SpellEvent, BuffSystem {
#define BUFF_ID 'A03C'
#define ART "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl"
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 7;
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        buf.bd.r0 = 0.5;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDCHARGEHEX, onCast);
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }
#undef ART
#undef BUFF_ID
}
//! endzinc
