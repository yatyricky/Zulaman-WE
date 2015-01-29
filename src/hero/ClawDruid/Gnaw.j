//! zinc
library Gnaw requires SpellEvent, GroupUtils, Rabies {
    function returnManaRegen(integer lvl) -> real {
        return 10.0 + 10 * lvl;
    }

    function onCast() {
        real aoe = 300.0;
        unit tu;
        Buff buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(RABIES_BUFF_ID);
        Buff tb;
        real regen = 0.0;
        real manaregen;
        integer lvl;
        if (buf != 0) {
            lvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDGNAW);
            manaregen = 0.0;
            GroupEnumUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.TargetUnit), GetUnitY(SpellEvent.TargetUnit), aoe, BOOLEXPR_TRUE);
            tu = FirstOfGroup(ENUM_GROUP);
            while (tu != null) {
                if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitEnemy(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                    if (!IsUnit(SpellEvent.TargetUnit, tu)) {
                        tb = Buff.cast(SpellEvent.CastingUnit, tu, RABIES_BUFF_ID);
                        tb.bd.tick = buf.bd.tick;
                        tb.bd.interval = buf.bd.interval;
                        tb.bd.r0 = buf.bd.r0;
                        tb.bd.i0 = buf.bd.i0;
                        tb.bd.boe = RabiesOnEffect;
                        tb.bd.bor = RabiesOnRemove;
                        tb.run();   
                        
                        AddTimedLight.atUnits("DRAL", SpellEvent.TargetUnit, tu, 0.5);                 
                    }
                    DamageTarget(SpellEvent.CastingUnit, tu, buf.bd.r0 * buf.bd.i0, SpellData[SIDRABIES].name, false, true, false, WEAPON_TYPE_WHOKNOWS);
                    regen += DamageResult.amount;
                    manaregen += returnManaRegen(lvl);
//BJDebugMsg("cannot understand");
                    
                    AddTimedEffect.atUnit(ART_BLEED, tu, "origin", 0.2);
                    AddTimedEffect.atUnit(ART_POISON, tu, "origin", 0.2);
                }
                GroupRemoveUnit(ENUM_GROUP, tu);
                tu = FirstOfGroup(ENUM_GROUP);
            }
            HealTarget(SpellEvent.CastingUnit, SpellEvent.CastingUnit, regen, SpellData[SIDGNAW].name, -3.0);
            ModUnitMana(SpellEvent.CastingUnit, manaregen);
            AddTimedEffect.atUnit(ART_HEAL, SpellEvent.CastingUnit, "origin", 0.2);
            AddTimedEffect.atUnit(ART_MANA, SpellEvent.CastingUnit, "origin", 0.2);
        }
        tu = null;
    }

    function onInit() {
        RegisterSpellEffectResponse(SIDGNAW, onCast);
    }
}
//! endzinc
