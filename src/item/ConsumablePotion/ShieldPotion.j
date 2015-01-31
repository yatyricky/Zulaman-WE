//! zinc
library ShieldPotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A081'
    
    function onEffect(Buff buf) {
    }
    
    function onRemove(Buff buf) {
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        buf.bd.isShield = true;
        buf.bd.r0 = 1000.0;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_SHIELD, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SHIELD_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
