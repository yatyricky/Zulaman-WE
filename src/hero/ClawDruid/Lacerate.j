//! zinc
library Lacerate requires BuffSystem, SpellEvent, UnitProperty, ClawDruidGlobal, AggroSystem {
    function returnDD(integer lvl) -> real {
        return 50.0 * lvl;
    }
    
    function returnDOT(integer lvl) -> real {
        return 50.0 * lvl;
    }

    public function RabiesOnEffect(Buff buf) {
        real dmg = buf.bd.r0;
        Buff debuff = BuffSlot[buf.bd.target].getBuffByBid(SAVAGE_ROAR_BUFF_ID);
        if (debuff != 0) {
        //BJDebugMsg("dmg amp> " + R2S(debuff.bd.r0));
            dmg *= (1.0 + debuff.bd.r0);
        }
        DamageTarget(buf.bd.caster, buf.bd.target, dmg, SpellData[SID_LACERATE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        if (!IsUnitDead(buf.bd.caster)) {
            AggroTarget(buf.bd.caster, buf.bd.target, dmg * 10.0);
        }
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }

    public function RabiesOnRemove(Buff buf) {
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, LACERATE_BUFF_ID);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_LACERATE);
        real dmg = returnDD(lvl) + UnitProp[SpellEvent.CastingUnit].AttackPower() * 0.3;
        Buff debuff = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(SAVAGE_ROAR_BUFF_ID);
        if (debuff != 0) {
            dmg *= (1.0 + debuff.bd.r0);
        }
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
        DamageTarget(buf.bd.caster, buf.bd.target, dmg, SpellData[SID_LACERATE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AggroTarget(buf.bd.caster, buf.bd.target, dmg * 5.0);
        
        buf.bd.interval = 2.0 / (1.0 + UnitProp[SpellEvent.CastingUnit].AttackSpeed() / 100.0);
        buf.bd.tick = Rounding(16.0 / buf.bd.interval);
        buf.bd.r0 = UnitProp[SpellEvent.CastingUnit].AttackPower() * 0.25 + returnDOT(lvl);
        buf.bd.boe = RabiesOnEffect;
        buf.bd.bor = RabiesOnRemove;
        buf.run();        
		// print("手贱");
    }

    function onInit() {
        BuffType.register(LACERATE_BUFF_ID, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_LACERATE, onCast);
    }
}
//! endzinc
