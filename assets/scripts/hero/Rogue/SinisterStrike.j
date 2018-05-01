//! zinc
library SinisterStrike requires DamageSystem, SpellEvent, RogueGlobal {
constant integer BUFF_ID = 'A046';
constant string  ART  = "Abilities\\Weapons\\KeeperGroveMissile\\KeeperGroveMissile.mdl";    

    function returnDamage(integer lvl, real ap) -> real {
        return (100 * lvl + ap * (0.4 + 0.6 * lvl));
    }

    function onEffect(Buff buf) {
        ModUnitMana(buf.bd.target, GetUnitState(buf.bd.target, UNIT_STATE_MAX_MANA) * 0.2);
    }

    function onRemove(Buff buf) {
    }
    
    function onCast() {
        real cost, amt, threshold, low;
        Buff buf;
        amt = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA);
        low = amt * 0.3;
        cost = GetUnitMana(SpellEvent.CastingUnit);
        if (cost >= low) {            
            threshold = amt * 0.4;
            if (cost > threshold) {
                cost = threshold;
            }
            //print("Mana used percent:" + R2S(cost / threshold));
            amt = returnDamage(GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SINISTER_STRIKE), UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower()) * cost / threshold;
            DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SID_SINISTER_STRIKE].name, true, true, true, WEAPON_TYPE_METAL_LIGHT_SLICE);
            ModUnitMana(SpellEvent.CastingUnit, 0 - cost);
            
            buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.CastingUnit, BUFF_ID);
            buf.bd.tick = 5;
            buf.bd.interval = 2;
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
            
            if (DamageResult.isHit) {
                DestroyEffect(AddSpecialEffectTarget(ART, DamageResult.target, "origin"));
                
                // equiped dagger of assassination
                if (HasDaggerOfAssassination(SpellEvent.CastingUnit) && GetRandomInt(0, 99) < 15) {
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
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
    }


}
//! endzinc
