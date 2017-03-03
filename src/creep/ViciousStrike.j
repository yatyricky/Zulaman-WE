//! zinc
library ViciousStrike {
// 险恶打击

// 目标单位每2秒昏迷1秒。

// |cff99ccff施法距离:|r 1200码
// |cff99ccff持续时间:|r 9秒
// |cff99ccff冷却时间:|r 12秒

// |cff6666ff魔法|r状态：目标单位每2秒昏迷1秒。

    function onEffect(Buff buf) {
        StunUnit(buf.bd.caster, buf.bd.target, 1.0);
        // AddTimedEffect.atUnit(ART_PLAGUE, buf.bd.target, "origin", 0.2);
    }

    function onRemove(Buff buf) {}

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, SID_VICIOUS_STRIKE);
        buf.bd.interval = 2.0;
        buf.bd.tick = 5;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        // AddTimedEffect.atUnit(ART_PLAGUE, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(BID_VICIOUS_STRIKE, BUFF_MAGE, BUFF_NEG);
        RegisterSpellEffectResponse(SID_VICIOUS_STRIKE, onCast);
    }
}
//! enzinc
