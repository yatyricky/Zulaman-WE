//! zinc
library FrostMageGlobal requires RageWinterchillsPhylactery {
    public function returnFrostDamage(unit caster) -> real {
        return (0.95 + 0.05 * GetUnitAbilityLevel(caster, SIDFROSTBOLT) + 0.05 * B2I(HasRageWinterchillsPhylactery(caster)));
    }
}
//! endzinc
