//! zinc
library Eviscerate requires DamageSystem, SpellEvent, RogueGlobal {
constant integer BUFF_ID = 'A047'; 
    
    function returnDD(integer lvl, real ap, integer cb) -> real {
        return ap * (0.4 * cb * lvl);
    }
    
    function returnDOT(integer lvl, real ap, integer cb) -> real {
        return 10.0 * cb * lvl + (0.1 + 0.02 * lvl) * cb * ap;
    }

    function onEffectDot(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData.inst(SID_EVISCERATE, SCOPE_PREFIX).name, true, true, false, WEAPON_TYPE_WHOKNOWS, false);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }

    function onRemoveDot(Buff buf) {
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }
    
    function onCast() {
        integer cp, lvl;
        real amt, cost, costp, max, ap, amp;
        Buff buf;
        cost = GetUnitMana(SpellEvent.CastingUnit);
        max = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA);
        costp = cost / max;
        if (costp >= 0.2) {
            if (ComboPoints[SpellEvent.CastingUnit].n > 0) {
                if (costp > 0.25) {
                    cost = max * 0.25;
                    costp = 1.0;
                } else {
                    costp = costp / 0.25;
                }
                ModUnitMana(SpellEvent.CastingUnit, 0 - cost);
            
            //print("Mana used percent:" + R2S(costp));
                lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_EVISCERATE);
                ap = UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackPower();
                cp = ComboPoints[SpellEvent.CastingUnit].get();
                amp = 1.0;
                if (GetUnitLifePercent(SpellEvent.TargetUnit) < 30) {
                    amp = 1.0 + ItemExAttributes.getUnitAttrVal(SpellEvent.CastingUnit, IATTR_RG_RUSH, SCOPE_PREFIX);
                }
                amt = returnDD(lvl, ap, cp) * costp * amp;
                DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData.inst(SID_EVISCERATE, SCOPE_PREFIX).name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE, false);
                if (DamageResult.isHit) {
                    DestroyEffect(AddSpecialEffectTarget(ART_GORE, DamageResult.target, "origin"));
                    
                    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = 8;
                    UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
                    buf.bd.i0 = 2 * cp;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                    
                    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_EVISCERATE);
                    buf.bd.interval = 3 / (1.0 + UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).AttackSpeed() / 100.0);
                    buf.bd.tick = Rounding(18.0 / buf.bd.interval);
                    buf.bd.r0 = returnDOT(lvl, ap, cp) * amp;
                    buf.bd.boe = onEffectDot;
                    buf.bd.bor = onRemoveDot;
                    buf.run();
                }
            }
        }
        //else {
        //    delayedDosth1.start(SpellEvent.CastingUnit);
        //}
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_EVISCERATE, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BID_EVISCERATE, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
