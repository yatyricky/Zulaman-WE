//! zinc
library LifeBloomHex requires BuffSystem, SpellEvent, UnitProperty, KeeperOfGroveGlobal {
constant integer BUFF_ID = 'A011';

    function onEffect(Buff buf) {
        if (buf.bd.tick != 1) {
            HealTarget(buf.bd.caster, buf.bd.target, 1000.0, SpellData.inst(SID_LIFE_BLOOMHEX, SCOPE_PREFIX).name, 0.0);
            AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.2);
        }
    }

    function onRemove(Buff buf) {
        HealTarget(buf.bd.caster, buf.bd.target, 2000.0, SpellData.inst(SID_LIFE_BLOOMHEX, SCOPE_PREFIX).name, 0.0);
        AddTimedEffect.atUnit(ART_HEAL, buf.bd.target, "origin", 0.2);
        //BJDebugMsg("����");
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.interval = 1.0 - UnitProp.inst(SpellEvent.CastingUnit, SCOPE_PREFIX).SpellHaste();
        buf.bd.tick = 9;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
    }

    function onInit() {
        //BuffType.register(BUFF_ID, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_LIFE_BLOOMHEX, onCast);
    }

}
//! endzinc
