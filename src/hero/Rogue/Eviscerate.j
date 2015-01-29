//! zinc
library Eviscerate requires DamageSystem, SpellEvent, RogueGlobal {
#define BUFF_ID 'A047' 
    
    /*struct delayedDosth1 {
        private timer tm;
        private unit u;
        private real amt;
    
        private static method run() {
            thistype this = GetTimerData(GetExpiredTimer());
            ModUnitMana(this.u, this.amt);
            ReleaseTimer(this.tm);
            this.tm = null;
            this.u = null;
            this.deallocate();
        }
    
        static method start(unit u) {
            thistype this = thistype.allocate();
            this.u = u;
            this.tm = NewTimer();
            this.amt = 50;
            SetTimerData(this.tm, this);
            TimerStart(this.tm, 0.01, false, function thistype.run);
        }
    }*/
    
    function returnDD(integer lvl, real ap, integer cb) -> real {
        return ap * (0.4 * cb * lvl);
    }
    
    function returnDOT(integer lvl, real ap, integer cb) -> real {
        return 10.0 * cb * lvl + (0.1 + 0.02 * lvl) * cb * ap;
    }

    function onEffectDot(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SIDEVISCERATE].name, true, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
    }

    function onRemoveDot(Buff buf) {
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }
    
    function onCast() {
        integer cp, lvl;
        real amt, cost, costp, max, ap;
        Buff buf;
        cost = GetUnitMana(SpellEvent.CastingUnit);
        max = GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA);
        costp = cost / max;
        if (costp >= 0.2) {        
            if (ComboPoints[SpellEvent.CastingUnit].isTarget(SpellEvent.TargetUnit) && ComboPoints[SpellEvent.CastingUnit].n > 0) {                
                if (costp > 0.25) {
                    cost = max * 0.25;
                    costp = 1.0;
                } else {
                    costp = costp / 0.25;
                }
                ModUnitMana(SpellEvent.CastingUnit, 0 - cost);
            
            //print("Mana used percent:" + R2S(costp));
                lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDEVISCERATE);
                ap = UnitProp[SpellEvent.CastingUnit].AttackPower();
                cp = ComboPoints[SpellEvent.CastingUnit].get();
                amt = returnDD(lvl, ap, cp) * costp;
                DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, amt, SpellData[SIDEVISCERATE].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
                if (DamageResult.isHit) {
                    DestroyEffect(AddSpecialEffectTarget(ART_GORE, DamageResult.target, "origin"));
                    
                    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
                    buf.bd.tick = -1;
                    buf.bd.interval = 8;
                    UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
                    buf.bd.i0 = 2 * cp;
                    buf.bd.boe = onEffect;
                    buf.bd.bor = onRemove;
                    buf.run();
                    
                    buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_EVISCERATE);
                    buf.bd.interval = 3 / (1.0 + UnitProp[SpellEvent.CastingUnit].AttackSpeed() / 100.0);
                    buf.bd.tick = Rounding(18.0 / buf.bd.interval);
                    buf.bd.r0 = returnDOT(lvl, ap, cp);
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
        RegisterSpellEffectResponse(SIDEVISCERATE, onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BID_EVISCERATE, BUFF_PHYX, BUFF_NEG);
    }
#undef BUFF_ID
}
//! endzinc
