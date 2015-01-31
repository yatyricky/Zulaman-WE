//! zinc
library ManaSourcePotion requires SpellEvent, BuffSystem {
#define BUFF_ID 'A07V'
    
    function onEffect(Buff buf) {
        //UnitProp[buf.bd.target].manaRegen += buf.bd.r0;
        ModUnitMana(buf.bd.target, GetUnitState(buf.bd.target, UNIT_STATE_MAX_MANA) * 0.3);
        AddTimedEffect.atUnit(ART_MANA, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {
        //UnitProp[buf.bd.target].manaRegen -= buf.bd.r0;
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = 5;
        buf.bd.interval = 1.0;
        //UnitProp[buf.bd.target].manaRegen -= buf.bd.r0;
        //buf.bd.r0 = 5;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_SOURCE_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }
#undef BUFF_ID
}
//! endzinc
