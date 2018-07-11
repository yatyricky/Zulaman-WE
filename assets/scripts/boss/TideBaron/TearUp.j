//! zinc
library TearUp requires BuffSystem, SpellEvent, UnitProperty, DamageSystem, TideBaronGlobal {
constant integer BUFF_ID = 'A04Z';
    function onEffect(Buff buf) {
        real amt = 400;
        if (GetUnitAbilityLevel(buf.bd.target, BUFF_ID_ALKALINE_WATER) > 0) {
            amt *= 3;
        }
        DamageTarget(buf.bd.caster, buf.bd.target, amt, SpellData.inst(SID_TEAR_UP, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {
    }

    function onCast() {
        Buff buf;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 20.0, SpellData.inst(SID_TEAR_UP, SCOPE_PREFIX).name, true, false, true, WEAPON_TYPE_METAL_LIGHT_SLICE, false);
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
        RegisterSpellEffectResponse(SID_TEAR_UP, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
