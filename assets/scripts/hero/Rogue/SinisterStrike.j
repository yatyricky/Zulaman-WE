//! zinc
library SinisterStrike requires DamageSystem, SpellEvent, RogueGlobal {

    function returnDamage(integer lvl, real ap) -> real {
        return ap * (1.25 + 0.25 * lvl);
    }

    function onEffectParalyze(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste -= buf.bd.r0;
    }
    
    function onRemoveParalyze(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
    }
    
    function CastParalysisPoison(unit caster, unit target) {
        Buff buf = Buff.cast(caster, target, BID_KELENS_DAGGER_OF_ASSASSINATION);
        buf.bd.tick = -1;
        buf.bd.interval = 9;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellHaste += buf.bd.r0;
        buf.bd.r0 = 0.2;
        buf.bd.boe = onEffectParalyze;
        buf.bd.bor = onRemoveParalyze;
        buf.run();
    }

    function onEffect(Buff buf) {
        ModUnitMana(buf.bd.target, 100);
    }

    function onCast() {
        real amt, amp;
        integer cp;
        Buff buf;
        amp = 1.0;
        if (GetUnitLifePercent(SpellEvent.TargetUnit) < 30) {
            amp = 1.0 + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_RUSH, SCOPE_PREFIX);
        }
        amt = returnDamage(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SINISTER_STRIKE), UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower()) * amp;
        if (IsUnitStealth(SpellEvent.CastingUnit)) {
            amt *= 3;
        }
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_SINISTER_STRIKE, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_LIGHT_SLICE, true);

        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_SINISTER_STRIKE);
        buf.bd.interval = 1.0 / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackSpeed() / 100.0);
        buf.bd.tick = Rounding(8.0 / buf.bd.interval);
        buf.bd.boe = onEffect;
        buf.bd.bor = Buff.noEffect;
        buf.run();

        if (DamageResult.isHit) {
            DestroyEffect(AddSpecialEffectTarget(ART_KEEPER_GROVE_MISSILE, DamageResult.target, "origin"));
            
            // equiped dagger of assassination
            if (UnitHasItemOfTypeBJ(SpellEvent.CastingUnit, ITID_KELENS_DAGGER_OF_ASSASSINATION) && GetRandomReal(0, 0.999) < ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_PARALZ, SCOPE_PREFIX)) {
                CastParalysisPoison(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
                cp = 2;
                AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 1.0);
            } else {
                cp = 1;
            }
            if (IsUnitStealth(SpellEvent.CastingUnit)) {
                cp = 5;
            }
            ComboPoints[SpellEvent.CastingUnit].add(cp);
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SINISTER_STRIKE, onCast);
        BuffType.register(BID_SINISTER_STRIKE, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_KELENS_DAGGER_OF_ASSASSINATION, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
