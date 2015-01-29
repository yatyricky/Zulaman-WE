//! zinc
library LifeBloom requires BuffSystem, SpellEvent, UnitProperty, KeeperOfGroveGlobal {
    function returnHOT(integer lvl, real sp) -> real {
        return 20.0 * lvl + sp * 0.2;
    }

    function returnDH(integer lvl, real sp) -> real {
        return 100 * lvl + sp * 1.4;
    }

    function onEffect(Buff buf) {
        if (buf.bd.tick != 1) {
            HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SIDLIFEBLOOM].name, 0.0);
            AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.2);
        }
    }

    function onRemove(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, buf.bd.r1, SpellData[SIDLIFEBLOOM].name, lbexcrit[GetPlayerId(GetOwningPlayer(buf.bd.caster))]);
        AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.2);
        //BJDebugMsg("ую╥е");   
        
        // equiped benediction
        //if (HasHornOfCenarius(buf.bd.caster)) {
        //    rejuv = BuffSlot[buf.bd.target].getBuffByBid(REJUVENATION_BUFF_ID);
        //    if (rejuv != 0) {
        //        rejuv.bd.tick = rejuvtick[GetPidofu(buf.bd.caster)];
        //    }
        //}
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_LIFE_BLOOM);
        real sp = UnitProp[SpellEvent.CastingUnit].SpellPower();
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDLIFEBLOOM);
        buf.bd.r0 = returnHOT(lvl, sp);
        buf.bd.r1 = returnDH(lvl, sp);
        buf.bd.interval = 1.0 / (1.0 + UnitProp[SpellEvent.CastingUnit].SpellHaste());
        buf.bd.tick = Rounding(lbtick[GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit))] / buf.bd.interval);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_LIFE_BLOOM, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SIDLIFEBLOOM, onCast);
    }
}
//! endzinc
