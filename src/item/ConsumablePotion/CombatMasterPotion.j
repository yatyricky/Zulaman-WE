//! zinc
library CombatMasterPotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A07Y'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModLife(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModLife(0 - buf.bd.i0);
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        UnitProp[buf.bd.target].ModLife(0 - buf.bd.i0);
        buf.bd.i0 = 300;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_COMBAT_MASTER_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
