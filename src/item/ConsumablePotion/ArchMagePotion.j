//! zinc
library ArchMagePotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A07X'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModMana(buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModMana(0 - buf.bd.i0);
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 30.0;
        UnitProp[buf.bd.target].ModMana(0 - buf.bd.i0);
        buf.bd.i0 = Rounding(GetUnitState(buf.bd.target, UNIT_STATE_MAX_MANA));
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ARCH_MAGE_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
