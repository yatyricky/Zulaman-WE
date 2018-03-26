//! zinc
library HolyShockHex requires SpellEvent, DamageSystem {
constant integer ART_ID = 'e00J';

    function onCast() {
        if (GetPidofu(SpellEvent.TargetUnit) == MOB_PID) {
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 3000.0, SpellData[SID_HOLY_SHOCK_HEX].name, 0.0);
        } else {
            DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 300.0, SpellData[SID_HOLY_SHOCK_HEX].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        }
        
        AddTimedEffect.byDummy(ART_ID, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HOLY_SHOCK_HEX, onCast);
    }

}
//! endzinc
