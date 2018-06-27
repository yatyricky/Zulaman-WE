//! zinc
library BreakLeg requires BuffSystem, DamageSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
    }

    function damaged() {
        Buff buf;
        if (GetUnitTypeId(DamageResult.source) != UTID_FENSTALKER) return;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;

        buf = Buff.cast(DamageResult.source, DamageResult.target, BID_BreakLeg);
        buf.bd.tick = -1;
        buf.bd.interval = 4.0;
        onRemove(buf);
        buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.75);
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_SLOW, buf, "origin");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_BreakLeg, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
