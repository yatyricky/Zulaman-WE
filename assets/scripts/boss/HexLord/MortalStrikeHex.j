//! zinc
library MortalStrikeHex requires BuffSystem, DamageSystem, UnitProperty {
constant integer BUFF_ID = 'A02O';
constant string  ART_TARGET  = "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl";

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
    }
    
    function onCast() {
        Buff buf; 
        real dmg = UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() + 300.0;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData.inst(SID_MORTAL_STRIKE_HEX, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE, false);
        if (DamageResult.isHit) {            
            AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.2);
            
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 4.0;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).healTaken += buf.bd.r0;
            buf.bd.r0 = 0.5;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_MORTAL_STRIKE_HEX, onCast);
    }
    


}
//! endzinc
