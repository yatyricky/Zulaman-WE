//! zinc
library Terror requires SpellEvent, StunUtils {
#define ART "Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl"

    public function HereticGetTerrorAOE(integer lvl) -> real {
        return 800.0;
    }

    function onCast() {
        //AddTimedEffect.atUnit("Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathMissile.mdl", SpellEvent.CastingUnit, "origin", 0.0);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDTERROR);
        real margin = 100 + 150.0 * lvl;
        unit tu;
        real time;
        real aoe = HereticGetTerrorAOE(lvl);
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), aoe);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                time = GetDistance.units2d(tu, SpellEvent.CastingUnit);
                if (time <= margin) {
                    time = 4.0;
                } else {
                    time = 4.0 - (time - margin) / (aoe - margin) * 3.0;
                }
                StunUnit(SpellEvent.CastingUnit, tu, time);
                //AddTimedEffect.atUnit(ART, tu, "origin", 3 + lvl);
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
        AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 0.1);
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDTERROR, onCast);
    }
#undef ART
}
//! endzinc
