//! zinc
library Discord requires SpellEvent, AggroSystem, BuffSystem {
#define ART "Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl"
#define BUFF_ID 'A030'

    function returnApDecPer(integer lvl) -> real {
        return 0.4 + 0.1 * lvl;
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].ModAP(0 - buf.bd.i0);
        UnitProp[buf.bd.target].ModAttackSpeed(buf.bd.i1);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].ModAP(buf.bd.i0);
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i1);
    }

    function onCast() {
        AggroList al = AggroList[SpellEvent.TargetUnit];
        unit target = al.sort();
        real aggro = al.getAggro(target);
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDDISCORD);
        Buff buf;
        if (!IsUnit(target, SpellEvent.CastingUnit)) {
            al.setAggro(SpellEvent.CastingUnit, aggro * 1.1);
        }        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp[buf.bd.target].ModAP(buf.bd.i0);
        UnitProp[buf.bd.target].ModAttackSpeed(0 - buf.bd.i1);
        buf.bd.i0 = Rounding(returnApDecPer(lvl) * UnitProp[SpellEvent.TargetUnit].AttackPower());
        buf.bd.i1 = 20;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_BLOOD_LUST_LEFT, buf, "hand, left");
        }
        if (buf.bd.e1 == 0) {
            buf.bd.e1 = BuffEffect.create(ART_BLOOD_LUST_RIGHT, buf, "hand, right");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();              
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDDISCORD, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }

#undef BUFF_ID
#undef ART
}
//! endzinc
