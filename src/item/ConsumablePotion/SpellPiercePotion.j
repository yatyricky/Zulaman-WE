//! zinc
library SpellPiercePotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A08B'
#define DEBUFF_ID 'A095'
    
    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].spellTaken += buf.bd.r0;
    }
    
    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit && !DamageResult.isPhyx) {
            if (BuffSlot[DamageResult.source].getBuffByBid(BUFF_ID) != 0) {
                buf = Buff.cast(DamageResult.source, DamageResult.target, DEBUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 5.0;
                UnitProp[buf.bd.target].spellTaken -= buf.bd.r0;
                buf.bd.r0 = 0.03;
                //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
                //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
                buf.bd.boe = onEffect1;
                buf.bd.bor = onRemove1;
                buf.run();
            }
        }
    }
    
    function onEffect(Buff buf) {}    
    function onRemove(Buff buf) {}

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SPELL_PIERCE_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        BuffType.register(DEBUFF_ID, BUFF_MAGE, BUFF_NEG);
        RegisterDamagedEvent(damaged);                
    }
#undef DEBUFF_ID
#undef BUFF_ID
}
//! endzinc
