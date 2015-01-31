//! zinc
library SpellMasteryPotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A088'
    
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].spellPower += buf.bd.r0;
        UnitProp[buf.bd.target].spellHaste += buf.bd.r1;
    }
    
    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellPower -= buf.bd.r0;
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r1;
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 2.0;
        UnitProp[buf.bd.target].spellPower -= buf.bd.r0;
        buf.bd.r0 = UnitProp[buf.bd.target].SpellPower();
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r1;
        buf.bd.r1 = 1.0;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SPELL_MASTER_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
