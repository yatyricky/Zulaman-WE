//! zinc
library SavageRoar requires BuffSystem, SpellEvent, UnitProperty, AggroSystem, Lacerate {

    function returnAPDec(integer lvl) -> real {
        return 0.05 * lvl;
    }
    
    function returnDmgAmp(integer lvl) -> real {
        return 0.08 * lvl;
    }
    
    function returnDuration(integer lvl) -> real {
        return 10.0;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
    }

    function onCast() {
        Buff buf;
        integer i = 0;
        real count = 0;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SAVAGE_ROAR);
        
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 600.0) {
                buf = Buff.cast(SpellEvent.CastingUnit, MobList.units[i], BID_SAVAGE_ROAR);
                buf.bd.tick = -1;
                buf.bd.interval = returnDuration(lvl);
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
                buf.bd.i0 = Rounding(returnAPDec(lvl) * UnitProp.inst(buf.bd.target, SCOPE_PREFIX).AttackPower());
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_HOWL_TARGET, buf, "overhead");}
                buf.bd.r0 = returnDmgAmp(lvl);
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
                
                count += 0.01;
                
                buf = BuffSlot[MobList.units[i]].getBuffByBid(BID_LACERATE);
                if (buf != 0) {
                    RabiesOnEffect(buf);
                }
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_ROAR_CASTER, SpellEvent.CastingUnit, "origin", 0.5);
        
        ModUnitMana(SpellEvent.CastingUnit, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA) * (0.25 + count));
    }

    function onInit() {
        BuffType.register(BID_SAVAGE_ROAR, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_SAVAGE_ROAR, onCast);
    }

}
//! endzinc
