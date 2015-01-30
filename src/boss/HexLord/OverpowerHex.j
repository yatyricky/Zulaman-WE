//! zinc
library OverpowerHex requires DamageSystem, CombatFacts {
    function dodged() {
        if (DamageResult.isDodged && GetUnitAbilityLevel(DamageResult.source, SIDOVERPOWERHEX) > 0) {
            DBMHexLord.canOverpower = true;
        }
    }
    
    function onCast() {
        if (DBMHexLord.canOverpower) {
            DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 700.0, SpellData[SIDOVERPOWERHEX].name, true, true, false, WEAPON_TYPE_METAL_HEAVY_CHOP);
            DBMHexLord.canOverpower = false;
        }
    }

    function onInit() {
        RegisterDamagedEvent(dodged);
        RegisterSpellEffectResponse(SIDOVERPOWERHEX, onCast);
    }
}
//! endzinc
