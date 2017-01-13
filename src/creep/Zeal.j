//! zinc
library Zeal {

    function onEffect(Buff buf) {
        UnitProp[buf.bd.caster].ModAP(50);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.caster].ModAP(0 - buf.bd.i0);
    }

    function damaged() {
        Buff buf;
        if (DamageResult.isHit && GetUnitTypeId(DamageResult.source) == UTID_CURSED_HUNTER) {
            buf = Buff.cast(DamageResult.source, DamageResult.source, BID_ZEAL);
            buf.bd.tick = -1;
            buf.bd.interval = 15.0;    
            buf.bd.i0 += 50;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        BuffType.register(BID_ZEAL, BUFF_PHYX, BUFF_POS);
        RegisterDamagedEvent(damaged);
    }
}
//! endzinc
