//! zinc
library Heal requires CastingBar, UnitProperty, PlayerUnitList {
#define ART "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl"

    public function PriestCastHeal(unit caster, unit target, real portion) {
        integer i = 0;
        real amt = (GetUnitAbilityLevel(caster, SIDHEAL) * 150 + UnitProp[caster].SpellPower()) * portion;
        integer count;
        AddTimedEffect.atUnit(ART, target, "origin", 0.3);
        HealTarget(caster, target, amt, SpellData[SIDHEAL].name, 0.0);
        count = 0;
        while (i < PlayerUnits.n) {  
            if (GetDistance.units2d(target, PlayerUnits.units[i]) < 301.0) {
                count += 1;
            }
            i += 1;
        }
        amt = HealResult.amount / count * 0.35;
        i = 0;
        while (i < PlayerUnits.n) {  
            if (GetDistance.units2d(target, PlayerUnits.units[i]) < 301.0) {
                HealTarget(caster, PlayerUnits.units[i], amt, SpellData[SIDHEAL].name, -3.0);
                AddTimedEffect.atUnit(ART, PlayerUnits.units[i], "origin", 0.3);
            }
            i += 1;
        }
    }

    function response(CastingBar cd) {
        PriestCastHeal(cd.caster, cd.target, 1.0);
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response);
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPRAYEROFHEALING) > 1) {
            cb.haste = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDPRAYEROFHEALING) * 0.25 - 0.25;
        }
        cb.launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SIDHEAL, onChannel);
    }
#undef ART
}
//! endzinc
