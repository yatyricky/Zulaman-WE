//! zinc
library Lacerate requires BuffSystem, SpellEvent, UnitProperty, AggroSystem {
    function returnDD(integer lvl) -> real {
        return 50.0 * lvl;
    }
    
    function returnDOT(integer lvl) -> real {
        return 50.0 * lvl;
    }

    public function RabiesOnEffect(Buff buf) {
        real dmg = buf.bd.r0;
        DamageTarget(buf.bd.caster, buf.bd.target, dmg, SpellData.inst(SID_LACERATE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, false);
        if (!IsUnitDead(buf.bd.caster)) {
            AggroTarget(buf.bd.caster, buf.bd.target, dmg * 10.0, SCOPE_PREFIX);
        }
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }

    public function RabiesOnRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_LACERATE);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_LACERATE);
        real dmg = returnDD(lvl) + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * 0.3;
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
        DamageTarget(buf.bd.caster, buf.bd.target, dmg, SpellData.inst(SID_LACERATE, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS, true);
        AggroTarget(buf.bd.caster, buf.bd.target, dmg * 5.0, SCOPE_PREFIX);
        
        buf.bd.interval = 2.0 / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackSpeed() / 100.0);
        buf.bd.tick = Rounding(16.0 / buf.bd.interval);
        buf.bd.r0 = UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * 0.25 + returnDOT(lvl);
        buf.bd.boe = RabiesOnEffect;
        buf.bd.bor = RabiesOnRemove;
        buf.run();
    }

    function onInit() {
        BuffType.register(BID_LACERATE, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_LACERATE, onCast);
    }

}
//! endzinc
