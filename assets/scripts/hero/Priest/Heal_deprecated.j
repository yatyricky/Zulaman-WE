//! zinc
library Heal requires CastingBar, UnitProperty, PlayerUnitList {
constant string  ART  = "Abilities\\Spells\\Demon\\DarkPortal\\DarkPortalTarget.mdl";

    public function PriestCastHeal(unit caster, unit target, real portion) {
        integer i = 0;
        real amt = (GetUnitAbilityLevel(caster, SID_HEAL) * 150 + UnitProp.inst(caster, SCOPE_PREFIX).SpellPower()) * portion;
        integer count;
        AddTimedEffect.atUnit(ART, target, "origin", 0.3);
        HealTarget(caster, target, amt, SpellData.inst(SID_HEAL, SCOPE_PREFIX).name, 0.0, false);
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
                HealTarget(caster, PlayerUnits.units[i], amt, SpellData.inst(SID_HEAL, SCOPE_PREFIX).name, -3.0, false);
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
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_PRAYER_OF_HEALING) > 1) {
            cb.haste = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_PRAYER_OF_HEALING) * 0.25 - 0.25;
        }
        cb.launch();
    }

    function onInit() {
        RegisterSpellChannelResponse(SID_HEAL, onChannel);
    }

}
//! endzinc
