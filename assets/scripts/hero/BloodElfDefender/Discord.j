//! zinc
library Discord requires SpellEvent, AggroSystem, BuffSystem {

    function returnApDecPer(integer lvl) -> real {
        return 0.4 + 0.1 * lvl;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
    }

    function onCast() {
        AggroList al = AggroList[SpellEvent.TargetUnit];
        unit target;
        real aggro;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DISCORD);
        Buff buf;
        if (al != 0 && IsUnitType(SpellEvent.TargetUnit, UNIT_TYPE_HERO) == false) {
            target = al.sort();
            aggro = al.getAggro(target);
            if (!IsUnit(target, SpellEvent.CastingUnit)) {
                al.setAggro(SpellEvent.CastingUnit, aggro * 1.1);
            }
        }

        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_DISCORD);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        buf.bd.i0 = Rounding(returnApDecPer(lvl) * UnitProp.inst(SpellEvent.TargetUnit, SCOPE_PREFIX).AttackPower());
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_HOWL_TARGET, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        target = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DISCORD, onCast);
        BuffType.register(BID_DISCORD, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
