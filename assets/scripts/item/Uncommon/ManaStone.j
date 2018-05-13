//! zinc
library ManaStone requires ItemAttributes {
    
    function onCast() {
        item ti;
        integer ii = 0;
        real amt = 0;
        while (ii < 6) {
            ti = UnitItemInSlot(SpellEvent.CastingUnit, ii);
            if (ti != null) {
                amt += ItemExAttributes.getAttributeValue(ti, IATTR_USE_MREGEN, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX) * 0.33);
            }
            ii += 1;
        }
        ti = null;
        ModUnitMana(SpellEvent.CastingUnit, amt);
        AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_MANA_STONE, onCast);
    }
}
//! endzinc
