//! zinc
library LifeLeech requires SpellEvent, DamageSystem, DarkRangerGlobal {

    function response() {
        if (DamageResult.isHit && GetUnitTypeId(DamageResult.source) == UTID_GHOUL) {
            AddTimedEffect.atUnit(ART_HEAL, DamageResult.source, "origin", 0.2);
            HealTarget(DamageResult.source, DamageResult.source, GetUnitState(DamageResult.source, UNIT_STATE_MAX_LIFE) * 0.05, SpellData[SID_LIFE_LEECH].name, -3.0);
        }
    }
    
    function onresponse() {
        if (GetUnitTypeId(DamageResult.source) == UTID_GHOUL) {
            DamageResult.amount += GetUnitState(DamageResult.source, UNIT_STATE_MAX_LIFE) * 0.05;
        }
    }

    function onInit() {
        RegisterOnDamageEvent(onresponse);
        RegisterDamagedEvent(response);
    }
}
//! endzinc
