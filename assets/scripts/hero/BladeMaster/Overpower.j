//! zinc
library Overpower requires DamageSystem, BladeMasterGlobal, Rend {
    function returnManaRegen(integer lvl) -> real {
        return 5.0 + 5 * lvl;
    }

    public function BladeMasterGetOverpowerManaRep(unit u) -> real {
        return returnManaRegen(GetUnitAbilityLevel(u, SID_OVER_POWER));
    }

    function returnExtraCriticalChance(integer lvl) -> real {
        return lvl * 0.25;
    }

    function dodged() {
        if (DamageResult.isDodged && GetUnitAbilityLevel(DamageResult.source, SID_OVER_POWER) > 0) {
            EnableOverpower(GetPlayerId(GetOwningPlayer(DamageResult.source)));
        }
    }
    
    function onCast() {
        real exct = returnExtraCriticalChance(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_OVER_POWER));
        KillUnit(premises[GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit))]);
        UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).attackCrit += exct;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower() * 1.5, SpellData[SID_OVER_POWER].name, true, true, false, WEAPON_TYPE_METAL_HEAVY_CHOP);
        UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).attackCrit -= exct;
        if (DamageResult.isHit) {
            ModUnitMana(DamageResult.source, returnManaRegen(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_OVER_POWER)));
            //if (GetUnitAbilityLevel(DamageResult.source, SPELL_ID_REND) > 0) {
            //    CastRend(DamageResult.source, DamageResult.target);
            //}
        }
    }

    function onInit() {
        RegisterDamagedEvent(dodged);
        RegisterSpellEffectResponse(SID_OVER_POWER, onCast);
    }
}
//! endzinc
