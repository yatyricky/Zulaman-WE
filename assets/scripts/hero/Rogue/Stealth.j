//! zinc
library Stealth requires AggroSystem, SpellEvent, UnitProperty, DamageSystem {

    unit premise[NUMBER_OF_MAX_PLAYERS];

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
    }
    
    function unstealth(unit u) {
        player p = GetOwningPlayer(u);
        Buff buf;
        if (IsInCombat() && !IsUnitDead(u)) {
            MobList.addToAll(u);
        }
        UnitRemoveAbility(u, SID_APIV);
        UnitProp.inst(u, SCOPE_PREFIX).ModSpeed(-60);
        
        if (!IsUnitDead(u)) {
            buf = Buff.cast(u, u, BID_STEALTH_AMP);
            buf.bd.tick = -1;
            buf.bd.interval = 10;
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
            buf.bd.r0 = 0.3;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_AVENGER_MISSILE, buf, "weapon");}
            //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_AVENGER_MISSILE, buf, "weapon, right");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }

        SetPlayerAbilityAvailable(p, SID_GARROTE, false);
        SetPlayerAbilityAvailable(p, SID_AMBUSH, false);        
        SetPlayerAbilityAvailable(p, SID_EVISCERATE, true);
        SetPlayerAbilityAvailable(p, SID_ASSAULT, true);
        premise[GetPlayerId(p)] = CreateUnit(p, UTID_NON_STEALTH, DUMMY_X, DUMMY_Y, 0.0);
        p = null;
    }
    
    function stealth(unit u) {
        player p = GetOwningPlayer(u);
        if (IsInCombat()) {
            MobList.clearForAll(u);
        }        

        SetPlayerAbilityAvailable(p, SID_EVISCERATE, false);
        SetPlayerAbilityAvailable(p, SID_ASSAULT, false);
        SetPlayerAbilityAvailable(p, SID_GARROTE, true);
        SetPlayerAbilityAvailable(p, SID_AMBUSH, true);
        
        UnitAddAbility(u, SID_APIV);
        UnitProp.inst(u, SCOPE_PREFIX).ModSpeed(60);
        AddTimedEffect.atCoord(ART_CloudOfFog, GetUnitX(u), GetUnitY(u), 1.0);
        
        KillUnit(premise[GetPlayerId(p)]);
        premise[GetPlayerId(p)] = null;
        
        p = null;
    }

    function onCast() {
        stealth(SpellEvent.CastingUnit);
    }
    
    function ruguedamaged() {
        if (GetUnitAbilityLevel(DamageResult.target, SID_APIV) > 0 && GetUnitAbilityLevel(DamageResult.target, SID_STEALTH) > 0) {
            unstealth(DamageResult.target);
        }
    }
    
    function attacked() -> boolean {
        unit u = null;
        if (GetUnitAbilityLevel(GetAttacker(), SID_APIV) > 0 && GetUnitAbilityLevel(GetAttacker(), SID_STEALTH) > 0) {
            u = GetAttacker();
        } else if (GetUnitAbilityLevel(GetTriggerUnit(), SID_APIV) > 0 && GetUnitAbilityLevel(GetTriggerUnit(), SID_STEALTH) > 0) {
            u = GetTriggerUnit();
        }
        if (u != null) {
            unstealth(u);
        }
        u = null;
        return false;
    }
    
    function onCastAnySpell() {
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_APIV) > 0 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SID_STEALTH) > 0) {
            unstealth(SpellEvent.CastingUnit);
        }
    }

    function onInit() {
        integer i;
        RegisterSpellEffectResponse(SID_STEALTH, onCast);
        RegisterSpellEffectResponse(0, onCastAnySpell);
        BuffType.register(BID_STEALTH_AMP, BUFF_PHYX, BUFF_POS);
        RegisterDamagedEvent(ruguedamaged);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ATTACKED, function attacked);
        
        i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            premise[i] = CreateUnit(Player(i), UTID_NON_STEALTH, DUMMY_X, DUMMY_Y, 0.0);
            i += 1;
        }
    }

}
//! endzinc
