//! zinc
library Lancinate requires BuffSystem, SpellEvent, UnitProperty, DamageSystem, TideBaronGlobal {
constant integer BUFF_ID = 'A050';
    function onEffect(Buff buf) {
        real amt = 250;
        if (GetUnitAbilityLevel(buf.bd.target, BUFF_ID_ALKALINE_WATER) > 0) {
            amt *= 3.0;
        }
        DamageTarget(buf.bd.caster, buf.bd.target, amt, SpellData.inst(SID_LANCINATE, SCOPE_PREFIX).name, true, false, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }
    
    function onRemove(Buff buf) {
    }

    function onCast() {
        Buff buf;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 450.0 + GetRandomReal(0.0, 100.0), SpellData.inst(SID_LANCINATE, SCOPE_PREFIX).name, true, false, true, WEAPON_TYPE_METAL_LIGHT_SLICE, false);
        if (DamageResult.isHit && !DamageResult.isBlocked) {
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
            buf.bd.tick = 5;
            buf.bd.interval = 1.0;          // interval
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_LANCINATE, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
