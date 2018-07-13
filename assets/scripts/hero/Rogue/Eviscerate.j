//! zinc
library Eviscerate requires DamageSystem, SpellEvent, RogueGlobal {
    
    function returnDD(integer lvl, real ap, integer cb) -> real {
        return cb * (100 * lvl + ap);
    }
    
    function onCast() {
        integer cp, lvl;
        real amt, ap, amp;
        Buff buf;
    
        lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EVISCERATE);
        ap = UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower();
        cp = ComboPoints[SpellEvent.CastingUnit].get();
        amp = 1.0;
        if (GetUnitLifePercent(SpellEvent.TargetUnit) < 30) {
            amp = 1.0 + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_RUSH, SCOPE_PREFIX);
        }
        amt = returnDD(lvl, ap, cp) * amp;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_EVISCERATE, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE, true);
        if (DamageResult.isHit) {
            DestroyEffect(AddSpecialEffectTarget(ART_GORE, DamageResult.target, "origin"));
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_EVISCERATE, onCast);
    }

}
//! endzinc
