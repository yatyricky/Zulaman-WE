//! zinc
library Overpower requires DamageSystem, BladeMasterGlobal, Rend {
    function returnManaRegen(integer lvl) -> real {
        return 5.0 + 5 * lvl;
    }

    public function BladeMasterGetOverpowerManaRep(unit u) -> real {
        return returnManaRegen(GetUnitAbilityLevel(u, SIDOVERPOWER));
    }

    function returnExtraCriticalChance(integer lvl) -> real {
        return lvl * 0.25;
    }

    function dodged() {
        if (DamageResult.isDodged && GetUnitAbilityLevel(DamageResult.source, SIDOVERPOWER) > 0) {
            EnableOverpower(GetPlayerId(GetOwningPlayer(DamageResult.source)));
        }
    }
    
    function onCast() {
        real exct = returnExtraCriticalChance(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDOVERPOWER));
        KillUnit(premises[GetPlayerId(GetOwningPlayer(SpellEvent.CastingUnit))]);
        UnitProp[SpellEvent.CastingUnit].attackCrit += exct;
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, UnitProp[SpellEvent.CastingUnit].AttackPower() * 1.5, SpellData[SIDOVERPOWER].name, true, true, false, WEAPON_TYPE_METAL_HEAVY_CHOP);
        UnitProp[SpellEvent.CastingUnit].attackCrit -= exct;
        if (DamageResult.isHit) {
            ModUnitMana(DamageResult.source, returnManaRegen(GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDOVERPOWER)));
            //if (GetUnitAbilityLevel(DamageResult.source, SPELL_ID_REND) > 0) {
            //    CastRend(DamageResult.source, DamageResult.target);
            //}
        }
    }

    function onInit() {
        RegisterDamagedEvent(dodged);
        RegisterSpellEffectResponse(SIDOVERPOWER, onCast);
    }
}
//! endzinc
