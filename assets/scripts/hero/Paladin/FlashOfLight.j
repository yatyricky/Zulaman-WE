//! zinc
library FlashOfLight requires SpellEvent, UnitProperty, BeaconOfLight, HolyLight {

    function returnHeal(integer lvl) -> real {
        return 200.0;
    }
    
    function returnExtraCritical(integer lvl) -> real {
        return lvl * 0.1;
    }

    function onCast() {
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FLASH_LIGHT);
        real amt = returnHeal(lvl) + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellPower() * 1.4;
        real exct = returnExtraCritical(lvl);
        BuffSlot bs = BuffSlot[SpellEvent.CastingUnit];
        Buff buf, dispel;
        // must crit
        buf = bs.getBuffByBid(BID_DIVINE_FAVOR_CRIT);
        if (buf != 0) {
            exct += 2.0;
            bs.dispelByBuff(buf);
            buf.destroy();
        }
        // heal
        HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_FLASH_LIGHT, SCOPE_PREFIX).name, exct, true);
        AddTimedEffect.atUnit(ART_HOLY_BOLT_SPECIAL_ART, SpellEvent.TargetUnit, "origin", 0.2);
        // instant holy light
        if (HealResult.isCritical) {
            if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_LIGHT) > 0) {
                ImproveHolyLight(SpellEvent.CastingUnit);
            }
        }
        // beacon of light
        BeaconOfLight[SpellEvent.CastingUnit].healBeacons(SpellEvent.TargetUnit, HealResult.amount, ART_HOLY_BOLT_SPECIAL_ART);
        // has lights justice
        if (UnitHasItemOfTypeBJ(SpellEvent.CastingUnit, ITID_LIGHTS_JUSTICE) == true) {
            dispel = BuffSlot[SpellEvent.TargetUnit].dispel(BUFF_MAGE, BUFF_NEG);
            if (dispel != 0) {
                dispel.destroy();
            }
            AddTimedEffect.atUnit(ART_DISPEL, SpellEvent.TargetUnit, "origin", 1.0);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FLASH_LIGHT, onCast);
    }
}
//! endzinc
