//! zinc
library BlazingHaste requires BuffSystem, SpellEvent, UnitProperty {
#define ART_FIRE "Environment\\SmallBuildingFire\\SmallBuildingFire1.mdl"

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].spellHaste += buf.bd.r0;
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r0;
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }

    function onCast() {
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BID_BLAZING_HASTE);
        buf.bd.tick = -1;
        buf.bd.interval = 20.0;
        UnitProp[buf.bd.target].spellHaste -= buf.bd.r0;
        //BJDebugMsg("Original Spell Speed: " + I2S(buf.bd.i0));
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 1000;
        //BJDebugMsg("New Speed mod: " + I2S(buf.bd.i0));
        buf.bd.r0 = 3.0;
        if (buf.bd.e0 == 0) {
            buf.bd.e0 = BuffEffect.create(ART_FIRE, buf, "origin");
        }
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        AddTimedEffect.atUnit(ART_RED_IMPACT, SpellEvent.TargetUnit, "origin", 0.2);
    }

    function onInit() {
        BuffType.register(BID_BLAZING_HASTE, BUFF_MAGE, BUFF_POS);
        RegisterSpellEffectResponse(SID_BLAZING_HASTE, onCast);
    }
#undef ART_FIRE
}
//! endzinc
