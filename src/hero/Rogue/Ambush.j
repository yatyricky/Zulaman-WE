//! zinc
library Ambush requires DamageSystem, SpellEvent, RogueGlobal {
#define ART "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl"
    
    function onCast() { 
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 300.0 + UnitProp[SpellEvent.CastingUnit].AttackPower(), SpellData[SIDAMBUSH].name, true, true, false, WEAPON_TYPE_METAL_HEAVY_SLICE);
        ComboPoints[SpellEvent.CastingUnit].add(SpellEvent.TargetUnit, 5);
        AddTimedEffect.atUnit(ART, SpellEvent.TargetUnit, "overhead", 1.0);
        StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 4.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDAMBUSH, onCast);
    }
#undef ART
}
//! endzinc
