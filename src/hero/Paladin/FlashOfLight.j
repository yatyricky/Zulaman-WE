//! zinc
library FlashOfLight requires PaladinGlobal, SpellEvent, UnitProperty, BeaconOfLight, HolyLight {
    function returnHeal(integer lvl) -> real {
        return 200.0;
    }
    
    function returnExtraCritical(integer lvl) -> real {
        return lvl * 0.1;
    }

    function onCast() {
        integer ilvl;
        real amt, exct;
        integer id = GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit));
        Buff buf;
        // get the right ability level
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FLASH_LIGHT) > 0) {
            ilvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FLASH_LIGHT);
        } else if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FLASH_LIGHT_1) > 0) {
            ilvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_FLASH_LIGHT_1);
        } else {
            ilvl = 0;
            print(SCOPE_PREFIX+">|cffff0000error|r.flash of light level = 0 and triggered");
        }
        // get the amount and heal
        amt = returnHeal(ilvl) + UnitProp[SpellEvent.CastingUnit].SpellPower() * 1.4;
        exct = healCrit[id] + returnExtraCritical(ilvl);
        buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BID_HOLY_LIGHT_AMP);
        if (buf != 0) {
            exct += buf.bd.r0;
        }
        HealTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID_FLASH_LIGHT].name, exct);
        if (healCrit[id] > 0) {
            healCrit[id] = 0.0;
        }
        AddTimedEffect.atUnit(ART_HOLY_BOLT_SPECIAL_ART, SpellEvent.TargetUnit, "origin", 0.2);
        // instant holy light
        if (HealResult.isCritical) {
            if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_HOLY_LIGHT) > 0) {
                ImproveHolyLight(SpellEvent.CastingUnit);
            }
        }
        // beacon of light
        BeaconOfLight[SpellEvent.CastingUnit].healBeacons(SpellEvent.TargetUnit, HealResult.amount, ART_HOLY_BOLT_SPECIAL_ART);
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FLASH_LIGHT, onCast);
        RegisterSpellEffectResponse(SID_FLASH_LIGHT_1, onCast);
    }
}
//! endzinc
