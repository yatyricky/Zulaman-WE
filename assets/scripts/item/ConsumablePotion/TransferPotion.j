//! zinc
library TransferPotion requires SpellEvent, BuffSystem {
constant integer BUFF_ID = 'A080';
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageGoesMana += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ml += buf.bd.r1;
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageGoesMana -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ml -= buf.bd.r1;
    }

    function onCast() {           
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageGoesMana -= buf.bd.r0;
        buf.bd.r0 = 0.1;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ml -= buf.bd.r1;
        buf.bd.r1 = 0.1;
        //if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TARGET, buf, "origin");}
        //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_RIGHT, buf, "hand, right");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_TRANSFER_POTION, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        
    }

}
//! endzinc
