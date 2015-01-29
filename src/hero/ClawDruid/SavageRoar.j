//! zinc
library SavageRoar requires BuffSystem, SpellEvent, UnitProperty, AggroSystem, Lacerate {
#define ART_DEBUFF "Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl"
#define ART_CASTER "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"

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
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAP(buf.bd.i0);
    }

    function onCast() {
        Buff buf;
        integer i = 0;
        real count = 0;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_SAVAGE_ROAR);
        
        while (i < MobList.n) {
            if (GetDistance.units2d(MobList.units[i], SpellEvent.CastingUnit) <= 600.0) {
                buf = Buff.cast(SpellEvent.CastingUnit, MobList.units[i], SAVAGE_ROAR_BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = returnDuration(lvl);
                UnitProp[buf.bd.target].ModAP(buf.bd.i0);
                buf.bd.i0 = Rounding(returnAPDec(lvl) * UnitProp[buf.bd.target].AttackPower());
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_DEBUFF, buf, "overhead");}
                buf.bd.r0 = returnDmgAmp(lvl);
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
                
                count += 0.01;
                
                buf = BuffSlot[MobList.units[i]].getBuffByBid(LACERATE_BUFF_ID);
                if (buf != 0) {
                    RabiesOnEffect(buf);
                }
            }
            i += 1;
        }
        AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "origin", 0.5);
        
        ModUnitMana(SpellEvent.CastingUnit, GetUnitState(SpellEvent.CastingUnit, UNIT_STATE_MAX_MANA) * (0.25 + count));
    }

    function onInit() {
        BuffType.register(SAVAGE_ROAR_BUFF_ID, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SID_SAVAGE_ROAR, onCast);
    }
#undef ART_CASTER
#undef ART_DEBUFF
}
//! endzinc
