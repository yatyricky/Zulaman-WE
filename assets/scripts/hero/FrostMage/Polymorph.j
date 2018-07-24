//! zinc
library Polymorph requires CastingBar, SpellReflection {

    unit sheepTarget[NUMBER_OF_MAX_PLAYERS];
    
    function onEffect(Buff buf) {
        Buff bufff;
        integer pid = GetPidofu(buf.bd.caster);
        // remove last
        if (sheepTarget[pid] != null) {
            if (sheepTarget[pid] != buf.bd.target) {
                bufff = BuffSlot[sheepTarget[pid]].getBuffByBid(BID_POLYMORPH);
                if (bufff != 0) {
                    BuffSlot[sheepTarget[pid]].dispelByBuff(bufff);
                    bufff.destroy();
                }
            }
        }
        // sheep effect
        if (!IsUnitBoss(buf.bd.target)) {
            DummyCast(buf.bd.caster, SID_POLYMORPH_DUMMY, "hex", buf.bd.target);
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).disabled += 1;
            sheepTarget[pid] = buf.bd.target;
            // slow
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(0 - buf.bd.i0);
        }
    }
    
    function onRemove(Buff buf) {
        if (GetUnitAbilityLevel(buf.bd.target, 'B00I') > 0) {
            UnitRemoveAbility(buf.bd.target, 'B00I');
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).disabled -= 1;
        }
        sheepTarget[GetPlayerId(GetOwningPlayer(buf.bd.caster))] = null;

        if (IsUnitBoss(buf.bd.target) == false) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModSpeed(buf.bd.i0);
        }
    }
    
    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_POLYMORPH);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_POLYMORPH);
        buf.bd.tick = -1;
        buf.bd.interval = 10.0;
        onRemove(buf);
        buf.bd.i0 = Rounding(UnitProp.inst(buf.bd.target, SCOPE_PREFIX).Speed() * 0.9);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        CounterSpell(SpellEvent.TargetUnit);
    }

    function onInit() {
        integer i;
        RegisterSpellEffectResponse(SID_POLYMORPH, onCast);
        BuffType.register(BID_POLYMORPH, BUFF_MAGE, BUFF_NEG);
        
        i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            sheepTarget[i] = null;
            i += 1;
        }
    }
}
//! endzinc
