//! zinc
library SpecialProperty requires DamageSystem, UnitProperty {
    function responseDamageGoesMana() {
        ModUnitMana(DamageResult.target, DamageResult.amount * UnitProp[DamageResult.target].DamageGoesMana());
    }
    
    function llandml() {
        UnitProp up = UnitProp[DamageResult.source];
        if (DamageResult.isHit && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (up.ll > 0.0) {
                HealTarget(DamageResult.source, DamageResult.source, DamageResult.amount * up.ll, SpellData[SIDATTACKLL].name, -3.0);
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
