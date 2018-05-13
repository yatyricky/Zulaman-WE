//! zinc
library HealthStone requires ItemAttributes {
    
    function onCast() {
        item ti;
        integer ii = 0;
        real amt = 0;
        while (ii < 6) {
            ti = UnitItemInSlot(SpellEvent.CastingUnit, ii);
            if (ti != null) {
                amt += ItemExAttributes.getAttributeValue(ti, IATTR_USE_HREGEN, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX) * 0.33);
            }
            ii += 1;
        }
        ti = null;
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, amt, SpellData.inst(SID_HEALTH_STONE, SCOPE_PREFIX).name, 0.0, false);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_HEALTH_STONE, onCast);
    }
}
//! endzinc
