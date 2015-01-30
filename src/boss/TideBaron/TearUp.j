//! zinc
library TearUp requires BuffSystem, SpellEvent, UnitProperty, DamageSystem, TideBaronGlobal {
#define BUFF_ID 'A04Z'
    function onEffect(Buff buf) {
        real amt = 180.0 + GetRandomReal(0.0, 40.0);
        if (GetUnitAbilityLevel(buf.bd.target, BUFF_ID_ALKALINE_WATER) > 0) {
            amt += amt;
        }
        DamageTarget(buf.bd.caster, buf.bd.target, amt, SpellData[SIDTEARUP].name, true, false, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {
    }

    function onCast() {
        Buff buf;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 20.0, SpellData[SIDTEARUP].name, true, false, true, WEAPON_TYPE_METAL_LIGHT_SLICE);
        if (DamageResult.isHit && !DamageResult.isBlocked) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = 6;
            buf.bd.interval = 2.0;          // interval
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDTEARUP, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }
#undef BUFF_ID
}
//! endzinc
