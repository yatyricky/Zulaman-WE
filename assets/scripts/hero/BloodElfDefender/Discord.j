//! zinc
library Discord requires SpellEvent, AggroSystem, BuffSystem {
constant string  ART  = "Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl";
constant integer BUFF_ID = 'A030';

    function returnApDecPer(integer lvl) -> real {
        return 0.4 + 0.1 * lvl;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(0 - buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i1);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
    }

    function onCast() {
        AggroList al = AggroList[SpellEvent.TargetUnit];
        unit target;
        real aggro;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_DISCORD);
        Buff buf;
        if (al != 0) {
            target = al.sort();
            aggro = al.getAggro(target);
            if (!IsUnit(target, SpellEvent.CastingUnit)) {
                al.setAggro(SpellEvent.CastingUnit, aggro * 1.1);
            }
        }

        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAP(buf.bd.i0);
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
        buf.bd.i0 = Rounding(returnApDecPer(lvl) * UnitProp.inst(SpellEvent.TargetUnit, SCOPE_PREFIX).AttackPower());
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
        target = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_DISCORD, onCast);
        BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
    }



}
//! endzinc
