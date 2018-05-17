//! zinc
library FrostMageGlobal {
    public function returnFrostDamage(unit caster) -> real {
        integer lvl = GetUnitAbilityLevel(caster, SID_FROST_BOLT);
        real famp = ItemExAttributes.getUnitAttrVal(caster, IATTR_MG_FDMG, SCOPE_PREFIX);
        if (lvl == 0 || lvl == 1) {
            return (1 + famp);
        } else {
            return (0.95 + 0.05 * lvl + famp);
        }
    }
}
//! endzinc
