//! zinc
library SpecialProperty requires DamageSystem, UnitProperty {
    function responseDamageGoesMana() {
        ModUnitMana(DamageResult.target, DamageResult.amount * UnitProp.inst(DamageResult.target, SCOPE_PREFIX).DamageGoesMana());
    }
    
    function llandml() {
        UnitProp up = UnitProp.inst(DamageResult.source, SCOPE_PREFIX);
        if (DamageResult.isHit && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (up.ll > 0.0) {
                HealTarget(DamageResult.source, DamageResult.source, DamageResult.amount * up.ll, SpellData[SID_ATTACK_LL].name, -3.0);
            }
            ModUnitMana(DamageResult.source, DamageResult.amount * up.ml);
        }
    }

    function onInit() {
        RegisterDamagedEvent(responseDamageGoesMana);
        RegisterDamagedEvent(llandml);
    }
}
//! endzinc
