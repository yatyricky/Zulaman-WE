//! zinc
library Mangle requires BuffSystem, SpellEvent, UnitProperty, ClawDruidGlobal, AggroSystem {

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i1);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i1);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, MANGLE_BUFF_ID);
        real dmg;
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        UnitProp[SpellEvent.TargetUnit].ModArmor(buf.bd.i1);
        buf.bd.i0 = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDMANGLE);
        buf.bd.i1 = 1 + buf.bd.i0 * 3;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        dmg = 100 * buf.bd.i0 + UnitProp[SpellEvent.CastingUnit].AttackPower();
        if (BuffSlot[SpellEvent.TargetUnit].getBuffByBid(RABIES_BUFF_ID) != 0) {
            dmg *= 1.2;
        }
        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDMANGLE].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_BASH);
        AggroTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg * 5.0);
        
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(MANGLE_BUFF_ID, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SIDMANGLE, onCast);
    }
}
//! endzinc
