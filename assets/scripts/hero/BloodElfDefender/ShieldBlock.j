//! zinc
library ShieldBlock requires BuffSystem, DamageSystem, SpellEvent, UnitProperty, AggroSystem {

    // 0.0~1.0
    function returnBlockRate(integer lvl) -> real {
        return 0.3 + lvl * 0.15;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).blockRate += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpellReflect(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).blockRate -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellReflect -= buf.bd.i0;
        if (UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellReflect < 0) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellReflect = 0;
        }
    }
    
    function paladinHitted() {
        Buff buf = BuffSlot[DamageResult.target].getBuffByBid(BID_SHIELD_BLOCK);
        if (buf != 0 && DamageResult.isBlocked) {
            if (GetDistance.units2d(DamageResult.source, DamageResult.target) < 200.0) {
                DelayedDamageTarget(DamageResult.target, DamageResult.source, buf.bd.r1, SpellData.inst(SID_SHIELD_BLOCK, SCOPE_PREFIX).name, false, false, false, WEAPON_TYPE_WHOKNOWS);
                AddTimedEffect.atUnit(ART_ThornsAuraDamage, DamageResult.source, "origin", 0.5);
                AggroTarget(DamageResult.target, DamageResult.source, buf.bd.r1 * 7.0, SCOPE_PREFIX);
            }
        }
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_SHIELD_BLOCK);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        onRemove(buf);
        buf.bd.i0 = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SHIELD_BLOCK);
        buf.bd.r0 = returnBlockRate(buf.bd.i0);
        buf.bd.r1 = UnitProp.inst(buf.bd.target, SCOPE_PREFIX).BlockPoint();
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_SpellShieldCaster, SpellEvent.CastingUnit, "origin", 0.1);
    }
    
    function onInit() {
        BuffType.register(BID_SHIELD_BLOCK, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_SHIELD_BLOCK, onCast);
        RegisterDamagedEvent(paladinHitted);
    }

}
//! endzinc
