//! zinc
library MortalStrike requires BladeMasterGlobal, Rend, BuffSystem, DamageSystem, UnitProperty, GroupUtils {
#define BUFF_ID 'A02O'
#define BUFF_ID1 'A02P'
#define ART_TARGET "Abilities\\Spells\\Orc\\Disenchant\\DisenchantSpecialArt.mdl"
#define ART_CASTER "Abilities\\Spells\\Other\\Andt\\Andt.mdl"
    
    function returnDamage(integer lvl, real ap) -> real {
        return 50 + 50 * lvl + ap * (1.5 + 0.5 * lvl);
    }
    
    function returnExtraCritBuff(integer lvl) -> real {
        return 0.05 * lvl - 0.05;
    }

    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].attackCrit += buf.bd.r0;
    }

    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].attackCrit -= buf.bd.r0;
    }

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].healTaken -= buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].healTaken += buf.bd.r0;
    }
    
    function onCast() {
        real dmg;
        integer ilvl;
        unit tu;
        // heal dec debuff
        Buff buf = Buff.cast(SpellEvent.CastingUnit, SpellEvent.TargetUnit, BUFF_ID);
        buf.bd.tick = -1;
        buf.bd.interval = 15.0;
        UnitProp[buf.bd.target].healTaken += buf.bd.r0;
        buf.bd.r0 = 0.5;
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        ilvl = GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDMORTALSTRIKE);
        dmg = returnDamage(ilvl, UnitProp[SpellEvent.CastingUnit].AttackPower());
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, dmg, SpellData[SIDMORTALSTRIKE].name, true, true, true, WEAPON_TYPE_METAL_HEAVY_SLICE);
        if (DamageResult.isHit) {            
            AddTimedEffect.atUnit(ART_TARGET, SpellEvent.TargetUnit, "origin", 0.2);
            // refresh Rend
            buf = BuffSlot[SpellEvent.TargetUnit].getBuffByBid(BUFF_ID_REND);
            if (buf != 0) {
                buf.bd.tick = buf.bd.i1;
            }
            AddTimedEffect.atUnit(ART_BLEED, SpellEvent.TargetUnit, "origin", 0.2);
            
            if (ilvl > 1) {
                // aoe increase critical chance
                AddTimedEffect.atUnit(ART_CASTER, SpellEvent.CastingUnit, "overhead", 0.15);
                GroupUnitsInArea(ENUM_GROUP, GetUnitX(SpellEvent.CastingUnit), GetUnitY(SpellEvent.CastingUnit), 450.);
                tu = FirstOfGroup(ENUM_GROUP);
                while (tu != null) {
                    GroupRemoveUnit(ENUM_GROUP, tu);
                    if (!IsUnitDummy(tu) && !IsUnitDead(tu) && IsUnitAlly(tu, GetOwningPlayer(SpellEvent.CastingUnit))) {
                        buf = Buff.cast(SpellEvent.CastingUnit, tu, BUFF_ID1);
                        buf.bd.tick = -1;
                        buf.bd.interval = 3.0;
                        UnitProp[buf.bd.target].attackCrit -= buf.bd.r0;
                        buf.bd.r0 = returnExtraCritBuff(ilvl);
                        buf.bd.boe = onEffect1;
                        buf.bd.bor = onRemove1;
                        buf.run();
                        AddTimedEffect.atUnit(ART_HEAL_SALVE, tu, "origin", 1.5);
                    }
                    tu = FirstOfGroup(ENUM_GROUP);
                }
            }
        }
        tu = null;
    }

    function onInit() {
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BUFF_ID1, BUFF_PHYX, BUFF_POS);
        RegisterSpellEffectResponse(SIDMORTALSTRIKE, onCast);
    }
    
#undef ART_CASTER
#undef ART_TARGET
#undef BUFF_ID1
#undef BUFF_ID
}
//! endzinc
