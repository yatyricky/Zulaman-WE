//! zinc
library ForkedLightning requires SpellEvent, DamageSystem {
    
    function onEffect(Buff buf) {}    
    function onRemove(Buff buf) {}

    function onCast() {
        unit tu;
        Buff buf, app;
        real amp;
        GroupUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit), DBMNagaSeaWitch.forkedLightningAOE);
        tu = FirstOfGroup(ENUM_GROUP);
        while (tu != null) {
            GroupRemoveUnit(ENUM_GROUP, tu);
            if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                // dmg & eff
                app = BuffSlot[tu].getBuffByBid(BID_FUCKED_LIGHTNING);
                if (app != 0) {
                    amp = 1.0 + app.bd.r0;
                } else {
                    amp = 1.0;
                }
                DamageTarget(SpellEvent.CastingUnit, tu, 300 * amp, SpellData[SID_FUCKED_LIGHTNING].name, false, false, false, WEAPON_TYPE_WHOKNOWS);  
                if (IsUnit(tu, SpellEvent.TargetUnit)) {
                    AddTimedLight.atUnits("CLPB", SpellEvent.CastingUnit, SpellEvent.TargetUnit, 0.5);
                } else {
                    AddTimedLight.atUnits("CLSB", SpellEvent.TargetUnit, tu, 0.5);
                }
                AddTimedEffect.atUnit(ART_IMPACT, tu, "origin", 0.1);
                // apply debuff
                buf = Buff.cast(SpellEvent.CastingUnit, tu, BID_FUCKED_LIGHTNING);
                buf.bd.tick = -1;
                buf.bd.interval = 10.0;
                buf.bd.r0 += 0.5;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
            tu = FirstOfGroup(ENUM_GROUP);
        }
        tu = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SID_FUCKED_LIGHTNING, onCast);
        BuffType.register(BID_FUCKED_LIGHTNING, BUFF_MAGE, BUFF_NEG);
    }
}
//! endzinc
