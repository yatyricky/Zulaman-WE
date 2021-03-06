//! zinc
library HealHex requires BuffSystem, SpellEvent, UnitProperty {
constant string  ART  = "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl";

    function onEffect(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, 2000.0, SpellData.inst(SID_HEAL_HEX, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART, buf.bd.target, "origin", 0.3);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_HEAL);
        buf.bd.tick = 4;
        buf.bd.interval = 2.0 * (1.0 - UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEAL_HEX, onCast);
    }

}
//! endzinc
