//! zinc
library Rend requires DamageSystem, SpellEvent, BuffSystem, BladeMasterGlobal {
    function returnDamage(integer lvl, real ap) -> real {
        return 20 + 60 * lvl + ap * 0.1;
    }

    boolean nextNormalCrit[NUMBER_OF_MAX_PLAYERS];
    
    function onEffect(Buff buf) {
        DamageTarget(buf.bd.caster, buf.bd.target, buf.bd.r0, SpellData[SIDREND].name, true, true, false, WEAPON_TYPE_WHOKNOWS);
        AddTimedEffect.atUnit(ART_BLEED, buf.bd.target, "origin", 0.2);
        // condition to enable next critical
        if (DamageResult.isCritical) {
            nextNormalCrit[GetPlayerId(GetOwningPlayer(buf.bd.caster))] = true;
        }
        // condition to enable overpower
        if (GetUnitAbilityLevel(buf.bd.caster, SIDOVERPOWER) > 0) {
            EnableOverpower(GetPlayerId(GetOwningPlayer(buf.bd.caster)));
        }
    }
    
    function onRemove(Buff buf) {
    }
    
    function onEffect1(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(0 - buf.bd.i0);
    }
    
    function onRemove1(Buff buf) {
        UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
    }
    
    public function CastRend(unit a, unit b) {
        Buff buf = Buff.cast(a, b, BUFF_ID_REND);
        buf.bd.interval = 2.5 / (1.0 + UnitProp[a].AttackSpeed() / 100.0);          // interval
        buf.bd.tick = Rounding(10.0 / buf.bd.interval) + 1;
        buf.bd.i0 = GetUnitAbilityLevel(a, SIDREND);
        buf.bd.i1 = buf.bd.tick;
        buf.bd.r0 = returnDamage(GetUnitAbilityLevel(a, SIDREND), UnitProp[a].AttackPower());
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        if (buf.bd.i0 > 1) {
            buf = Buff.cast(a, b, BUFF_ID_REND1);
            buf.bd.tick = -1;
            buf.bd.interval = 7.0;
            UnitProp[buf.bd.target].ModSpeed(buf.bd.i0);
            buf.bd.i0 = Rounding(UnitProp[buf.bd.target].Speed() * 0.45);
            buf.bd.boe = onEffect1;
            buf.bd.bor = onRemove1;
            buf.run();
        }
    }
    
    function onCast() {
        DamageTarget(SpellEvent.CastingUnit, SpellEvent.TargetUnit, 20.0, SpellData[SIDREND].name, true, false, true, WEAPON_TYPE_METAL_LIGHT_SLICE);
        if (DamageResult.isHit && !DamageResult.isBlocked) {
            CastRend(SpellEvent.CastingUnit, SpellEvent.TargetUnit);
        }
    }
    
    function ondamageresponse() {
        if (nextNormalCrit[GetPlayerId(GetOwningPlayer(DamageResult.source))] && (DamageResult.abilityName == DAMAGE_NAME_MELEE || DamageResult.abilityName == SpellData[SIDHEROICSTRIKE].name)) {
            //BJDebugMsg("next must crit");
            DamageResult.extraCrit = 1.0;
            nextNormalCrit[GetPlayerId(GetOwningPlayer(DamageResult.source))] = false;
            //BJDebugMsg("value false");
        }
    }

    function onInit() {
        integer i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            nextNormalCrit[i] = false;
            i += 1;
        }
        BuffType.register(BUFF_ID_REND, BUFF_PHYX, BUFF_NEG);
        BuffType.register(BUFF_ID_REND1, BUFF_PHYX, BUFF_NEG);
        RegisterSpellEffectResponse(SIDREND, onCast);
        RegisterOnDamageEvent(ondamageresponse);
    }
}
//! endzinc
