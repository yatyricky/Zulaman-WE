//! zinc
library ArmorCrushing requires SpellEvent, BuffSystem {
#define BUFF_ID 'A09W'

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }
    
    function onCast() {       
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 7;
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
        buf.bd.i0 = 50;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ARMOR_CRUSHING, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
    
#undef BUFF_ID
}
//! endzinc
