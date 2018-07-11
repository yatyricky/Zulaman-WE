//! zinc
library InvulPotion requires SpellEvent, BuffSystem {
    
    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += buf.bd.r0;
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_INVUL_POTION);
        buf.bd.tick = -1;
        buf.bd.interval = 8.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
        buf.bd.r0 = -1.0;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_INVULNERABLE, buf, "origin");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_INVUL_POTION, onCast);
        BuffType.register(BID_INVUL_POTION, BUFF_MAGE, BUFF_POS);
    }

}
//! endzinc
