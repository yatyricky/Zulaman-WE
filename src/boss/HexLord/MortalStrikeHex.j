//! zinc
library MortalStrikeHex requires BuffSystem, DamageSystem, UnitProperty {
#define BUFF_ID 'A02O'
#define ART_TARGET "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl"

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].healTaken += buf.bd.r0;
    }
    
    function onCast() {
        Buff buf; 
        real dmg = UnitProp[SpellEvent.CastingUnit].AttackPower() + 300.0;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDMORTALSTRIKEHEX].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
        if (DamageResult.isHit) {            
            AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.2);
            
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 4.0;
            UnitProp[buf.bd.target].healTaken += buf.bd.r0;
            buf.bd.r0 = 0.5;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SIDMORTALSTRIKEHEX, onCast);
    }
    
#undef ART_TARGET
#undef BUFF_ID
}
//! endzinc
