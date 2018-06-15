//! zinc
library SwiftMend requires SpellEvent, DamageSystem {

    function returnArmor(integer lvl) -> real {
        return 0.1 * lvl - 0.1;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).dodge -= buf.bd.r0;
    }

    function onCast() {
        BuffSlot bs = BuffSlot[SpellEvent.TargetUnit];
        Buff buf = bs.getBuffByBid(BID_REGROWTH);
        integer ilvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SWIFT_MEND);
        if (buf != 0) {
            AddTimedEffect.atUnit(ART_ENT_BIRTH_TARGET, SpellEvent.TargetUnit, "origin", 0.3);
            AddTimedEffect.atUnit(ART_ReplenishHealthCasterOverhead, SpellEvent.TargetUnit, "overhead", 0.3);
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, buf.bd.r0 * 5, SpellData.inst(SID_SWIFT_MEND, SCOPE_PREFIX).name, 0.0, true);
        } else {
            buf = bs.getBuffByBid(BID_REJUVENATION);
            if (buf != 0) {
            AddTimedEffect.atUnit(ART_ENT_BIRTH_TARGET, SpellEvent.TargetUnit, "origin", 0.3);
            AddTimedEffect.atUnit(ART_ReplenishHealthCasterOverhead, SpellEvent.TargetUnit, "overhead", 0.3);
                HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, buf.bd.r0 * buf.bd.i1, SpellData.inst(SID_SWIFT_MEND, SCOPE_PREFIX).name, 0.0, true);
            }
        }
        if (buf != 0 && ilvl < 3) {
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        if (ilvl > 1) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_SWIFT_MEND);
            buf.bd.tick = -1;
            buf.bd.interval = 10.0;
            UnitProp.inst(SpellEvent.TargetUnit, SCOPE_PREFIX).dodge -=buf.bd.r0;
            buf.bd.r0 = returnArmor(ilvl);
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_ClarityTarget, buf, "origin");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        BuffType.register(BID_SWIFT_MEND, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_SWIFT_MEND, onCast);
    }

}
//! endzinc
