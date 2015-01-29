//! zinc
library SurvivalInstincts requires BuffSystem, SpellEvent, UnitProperty, ReforgedBadgeOfTenacity {
#define BUFF_ID 'A0A3'
#define ART "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"

    function returnPercent(integer lvl) -> real {
        return 0.2 + 0.1 * lvl;
    }
    
    function returnDuration(integer lvl) -> real {
        return 2.0 + 3.0 * lvl;
    }
    
    function returnDmgReduc(integer lvl) -> real {
        return 0.15 * lvl - 0.1;
    }

    // i0 = current increment; i1 = final decrement
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModLife(buf.bd.i0);
        UnitProp[buf.bd.target].damageTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModLife(0 - buf.bd.i1);
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SURVIVAL_INSTINCTS);
        real percentage;
        buf.bd.tick = -1;
        buf.bd.interval = returnDuration(lvl);
        percentage = returnPercent(lvl);
        
        // equiped reforged badge of tenacity
        if (HasReforgedBadgeOfTenacity(SpellEvent.CastingUnit)) {
            percentage += 0.15;
        }
        
        buf.bd.i0 = R2I(GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * percentage);
        buf.bd.i1 += buf.bd.i0;
        UnitProp[buf.bd.target].damageTaken += buf.bd.r0;
        buf.bd.r0 = returnDmgReduc(lvl);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_LIFE) * percentage, SpellData[SID_SURVIVAL_INSTINCTS].name, -3.0);
        AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
        AddTimedEffect.atUnit(ART, SpellEvent.CastingUnit, "origin", 1.0);
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SID_SURVIVAL_INSTINCTS, onCast);
    }
#undef ART
#undef BUFF_ID 
}
//! endzinc
