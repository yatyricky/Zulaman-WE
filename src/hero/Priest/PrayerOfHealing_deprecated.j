//! zinc
library PrayerOfHealing requires CastingBar, UnitProperty, PlayerUnitList {
#define ART "Abilities\\Spells\\Orc\\EtherealForm\\SpiritWalkerChange.mdl"

    function response(CastingBar cd) {
        integer i = 0;
        integer lvl = GetUnitAbilityLevel(cd.caster, SIDPRAYEROFHEALING);
        real excrit;
        real percent;
        AddTimedEffect.atCoord(ART, GetUnitX(cd.caster), GetUnitY(cd.caster), 0.3);
        while (i < PlayerUnits.n) {  
            percent = GetUnitStatePercent(PlayerUnits.units[i], UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE);
            if (percent >= 25 + 15 * lvl) {
                excrit = 0.0;
            } else if (percent < 15 * lvl - 5) {                
                excrit = 0.2 + lvl * 0.1;
            } else {
                excrit = (25 + 15 * lvl - percent) / 30.0 * (0.2 + lvl * 0.1);
            }
            HealTarget(cd.caster, PlayerUnits.units[i], 300.0 + UnitProp[cd.caster].SpellPower(), SpellData[SIDPRAYEROFHEALING].name, excrit);
            AddTimedLight.atUnits("HWSB", cd.caster, PlayerUnits.units[i], 0.25);
            i += 1;
        }
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        cb.haste = -0.25 + GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPRAYEROFHEALING) * 0.25;
        cb.launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDPRAYEROFHEALING, onChannel);
    }
#undef ART
}
//! endzinc
