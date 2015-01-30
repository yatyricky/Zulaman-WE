//! zinc
library MangleHex requires BuffSystem, SpellEvent, UnitProperty {
    public constant integer MANGLEHEX_BUFF_ID = 'A05U';

    function onEffect(Buff buf) {}
    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, MANGLEHEX_BUFF_ID);
        real dmg;
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        dmg = 200 + UnitProp[SpellEvent.CastingUnit].AttackPower();        
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDMANGLEHEX].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_BASH);
        
        AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDMANGLEHEX, onCast);
        BuffType.register(MANGLEHEX_BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
}
//! endzinc
