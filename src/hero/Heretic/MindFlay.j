//! zinc
library MindFlay requires CastingBar, GroupUtils {
#define ART_CASTER "Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl"
#define ART_TARGET "Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl"

    function returnDamage(integer lvl, real sp) -> real {
        return 50.0 + 50.0 * lvl + sp * 0.1;
    }
    
    function returnManaConvertRateSelf(integer lvl) -> real {
        return 0.15 + 0.05 * lvl;
    }
    
    function returnManaConvertRateAlly(integer lvl) -> real {
        return 0.10 * lvl - 0.05;
    }

    function response(CastingBar cd) {
        integer lvl = GetUnitAbilityLevel(cd.caster, SIDMINDFLAY);
        real dmg = returnDamage(lvl, UnitProp[cd.caster].SpellPower());
        real rate;
        unit tu;
        //BJDebugMsg("Run !");
        DamageTarget(cd.caster, cd.target, dmg, SpellData[SIDMINDFLAY].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        ModUnitMana(cd.caster, dmg * returnManaConvertRateSelf(lvl));
        rate = returnManaConvertRateAlly(lvl);
        if (lvl > 1) {
            lvl -= 2;
            GroupUnitsInArea(ENUM_GROUP, GetUnitX(cd.caster), GetUnitY(cd.caster), 350.);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                GroupRemoveUnit(ENUM_GROUP, tu);
                if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitAlly(tu, GetOwningPlayer(cd.caster)) && !IsUnit(tu, cd.caster)) {
                    ModUnitMana(tu, dmg * rate);
                    AddTimedEffect.atUnit(ART_MANA, tu, "origin", 0.2);
                }
                tu = FirstOfGroup(ENUM_GROUP);
            }
        }
        tu = null;
    }
    
    function onChannel() {
        CastingBar cb = CastingBar.create(response).setSound(castSound);
        cb.e0 = AddSpecialEffectTarget(ART_CASTER, SpellEvent.CastingUnit, "chest");
        cb.e1 = AddSpecialEffectTarget(ART_TARGET, SpellEvent.TargetUnit, "chest");
        cb.l0 = CastAttachLightning.atUnits("DRAM", SpellEvent.CastingUnit, SpellEvent.TargetUnit);
        //BJDebugMsg("Createed");
        cb.channel(Rounding(3.0 * (1.0 + UnitProp[SpellEvent.CastingUnit].SpellHaste())));
        //AddTimedLight.atUnits("DRAM", SpellEvent.CastingUnit, SpellEvent.TargetUnit, cb.r0);
        //AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "chest", cb.r0);
        //AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "chest", cb.r0);
    }
    
    integer castSound;

    function onInit() {
        castSound = DefineSound("Abilities\\Spells\\Undead\\UndeadMine\\AcolyteMining.wav", 4233, false, false);
        RegisterSpellChannelResponse(SIDMINDFLAY, onChannel);
    }
#undef ART_TARGET
#undef ART_CASTER
}
//! endzinc
