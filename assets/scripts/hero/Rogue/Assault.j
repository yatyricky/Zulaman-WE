//! zinc
library Assault requires DamageSystem, SpellEvent, RogueGlobal, StunUtils {

    function returnStun(integer lvl, integer cp) -> integer {
        return lvl + cp;
    }

    function returnSunderArmor(integer lvl, integer cp) -> integer {
        integer ep = 1;
        if (lvl == 2) {ep = 2;}
        if (lvl >= 3) {ep = 4;}
        return ep * cp;
    }

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }

    function onCast() {
        Buff buf;
        integer lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_ASSAULT);
        integer cp = ComboPoints[SpellEvent.CastingUnit].get();

        StunUnit(SpellEvent.CastingUnit, SpellEvent.TargetUnit, returnStun(lvl, cp));
        
        buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_ASSAULT);
        buf.bd.tick = -1;
        buf.bd.interval = 8;
        onRemove(buf);
        buf.bd.i0 = returnSunderArmor(lvl, cp);
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();

        DestroyEffect(AddSpecialEffectTarget(ART_BallistaMissileTarget, DamageResult.target, "origin"));
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_ASSAULT, onCast);
        BuffType.register(BID_ASSAULT, BUFF_PHYX, BUFF_NEG);
    }

}
//! endzinc
