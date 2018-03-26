//! zinc
library Ambush requires DamageSystem, SpellEvent, RogueGlobal {
constant string  ART  = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl";
    
    function onCast() { 
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 300.0 + UnitProp[SpellEvent.CastingUnit].AttackPower(), SpellData[SID_AMBUSH].name, true, true, false, WEAPON_TYPE_METAL_HEAVY_SLICE);
        ComboPoints[SpellEvent.CastingUnit].add(SpellEvent.TargetUnit, 5);
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "overhead", 1.0);
        StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 4.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_AMBUSH, onCast);
    }

}
//! endzinc
