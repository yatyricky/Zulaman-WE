//! zinc
library SinisterStrike requires DamageSystem, SpellEvent, RogueGlobal {

    function returnDamage(integer lvl, real ap) -> real {
        return (100 * lvl + ap * (0.4 + 0.6 * lvl));
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
        ModUnitMana(buf.bd.target, GetUnitState(buf.bd.target, UNIT_STATE_MAX_MANA) * 0.2);
    }

    function onRemove(Buff buf) {
    }
    
    function onCast() {
        real cost, amt, threshold, low, amp;
        Buff buf;
        amt = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA);
        low = amt * 0.3;
        cost = GetUnitMana(SpellEvent.CastingUnit);
        if (cost >= low) {
            threshold = amt * 0.4;
            if (cost > threshold) {
                cost = threshold;
            }
            amp = 1.0;
            if (GetUnitLifePercent(SpellEvent.TargetUnit) < 30) {
                amp = 1.0 + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_RUSH, SCOPE_PREFIX);
            }
            //print("Mana used percent:" + R2S(cost / threshold));
            amt = (returnDamage(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SINISTER_STRIKE), UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower()) * cost / threshold) * amp;
            DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_SINISTER_STRIKE, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_LIGHT_SLICE, false);
            ModUnitMana(SpellEvent.CastingUnit, 0 - cost);
            
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BID_SINISTER_STRIKE);
            buf.bd.tick = 5;
            buf.bd.interval = 2;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            
            if (DamageResult.isHit) {
                DestroyEffect(AddSpecialEffectTarget(ART_KEEPER_GROVE_MISSILE, DamageResult.target, "origin"));
                
                // equiped dagger of assassination
                if (UnitHasItemOfTypeBJ(SpellEvent.CastingUnit, ITID_KELENS_DAGGER_OF_ASSASSINATION) && GetRandomReal(0, 0.999) < ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_PARALZ, SCOPE_PREFIX)) {
                    CastParalysisPoison(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
                    ComboPoints[SpellEvent.CastingUnit].add(DamageResult.target, 2);
                    AddTimedEffect.atUnit(ART_POISON, DamageResult.target, "origin", 1.0);
                } else {
                    ComboPoints[SpellEvent.CastingUnit].add(DamageResult.target, 1);
                }
            }
        }
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_SINISTER_STRIKE, onCast);
        BuffType.register(BID_SINISTER_STRIKE, BUFF_MAGE, BUFF_POS);
        BuffType.register(BID_KELENS_DAGGER_OF_ASSASSINATION, BUFF_MAGE, BUFF_NEG);
    }


}
//! endzinc
