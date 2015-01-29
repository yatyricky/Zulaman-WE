//! zinc
library Garrote requires DamageSystem, SpellEvent, RogueGlobal {
#define BUFF_ID 'A04P'
#define ART "Abilities\\Spells\\NightElf\\shadowstrike\\shadowstrike.mdl"    

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SIDGARROTE].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        CounterSpell(buf.bd.target);
    }

    function onRemove(Buff buf) {}
    
    function onCast() { 
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = 3;
        buf.bd.interval = 4;
        buf.bd.r0 = 75.0 + UnitProp[SpellEvent.CastingUnit].AttackPower() * 0.33;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        ComboPoints[SpellEvent.CastingUnit].add(SpellEvent.TargetUnit, 2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDGARROTE, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }
#undef ART
#undef BUFF_ID
}
//! endzinc
