//! zinc
library PainHex requires BuffSystem, SpellEvent, UnitProperty, SpellReflection {
constant integer BUFF_ID = 'A01V';
constant integer BUFF_ID1 = 'A021';

    function onEffect1(Buff buf) { 
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
    }

    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, 200.0, SpellData.inst(SID_PAIN_HEX, SCOPE_PREFIX).name, false, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        unit tmp;
        Buff buf;
        if (TryReflect(SpellEvent.TargetUnit)) {
            tmp = SpellEvent.CastingUnit;
            SpellEvent.CastingUnit = SpellEvent.TargetUnit;
            SpellEvent.TargetUnit = tmp;
        }
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = 4;
        buf.bd.interval = 2.0 * (1.0 - UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID1);
        buf.bd.tick = -1;
        buf.bd.interval = 8;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).spellTaken -= buf.bd.r0;
        buf.bd.r0 = 0.3;
        buf.bd.boe = onEffect1;
        buf.bd.bor = onRemove1;
        buf.run();
        AddTimedEffect.atUnit(ART_PLAGUE, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_NEG);
        //BuffType.register(BUFF_ID1, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_PAIN_HEX, onCast);
    }


}
//! endzinc
