//! zinc
library HealHex requires BuffSystem, SpellEvent, UnitProperty {
#define BUFF_ID 'A03X'
#define ART "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl"

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, 2000.0, SpellData[SIDHEALHEX].name, 0.0);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = 4;
        buf.bd.interval = 2.0 * (1.0 - UnitProp[SpellEvent.CastingUnit].SpellHaste());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 1.0);
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SIDHEALHEX, onCast);
    }
#undef ART
#undef BUFF_ID
}
//! endzinc
