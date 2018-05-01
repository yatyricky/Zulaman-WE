//! zinc
library HolyShockHex requires SpellEvent, DamageSystem {

    function onCast() {
        if (GetPidofu(SpellEvent.TargetUnit) == MOB_PID) {
            HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 3000.0, SpellData[SID_HOLY_SHOCK_HEX].name, 0.0);
        } else {
            DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 300.0, SpellData[SID_HOLY_SHOCK_HEX].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        }
        
        AddTimedEffect.atPos(ART_FAERIE_DRAGON_MISSILE, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit), GetUnitZ(SpellEvent.TargetUnit) + 24.0, 0, 3);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HOLY_SHOCK_HEX, onCast);
    }

}
//! endzinc
