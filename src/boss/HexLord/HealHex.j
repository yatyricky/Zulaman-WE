//! zinc
library HealHex requires BuffSystem, SpellEvent, UnitProperty {
constant integer BUFF_ID = 'A03X';
constant string  ART  = "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl";

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, 2000.0, SpellData[SID_HEAL_HEX].name, 0.0);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = 4;
        buf.bd.interval = 2.0 * (1.0 - UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 1.0);
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_HEAL_HEX, onCast);
    }


}
//! endzinc
