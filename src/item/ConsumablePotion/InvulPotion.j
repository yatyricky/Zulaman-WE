//! zinc
library InvulPotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A085'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
        buf.bd.r0 = -1.0;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_INVUL_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
