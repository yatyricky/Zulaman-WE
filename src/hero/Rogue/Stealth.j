//! zinc
library Stealth requires AggroSystem, SpellEvent, UnitProperty, DamageSystem {
#define ART "Abilities\\Spells\\Human\\CloudOfFog\\CloudOfFog.mdl"
#define ART_WEAPON "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
#define BUFF_ID 'A049'
#define PREMISE_ID 'e003'
// rogue damaged
// rogue use spell
// rogue attack/attacked

    unit premise[NUMBER_OF_MAX_PLAYERS];

    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
    }
    
    function unstealth(unit u) {
        player p = GetOwningPlayer(u);
        Buff buf;
        if (IsInCombat() && !IsUnitDead(u)) {
            MobList.addToAll(u);
        }
        UnitRemoveAbility(u, SIDAPIV);
        UnitProp[u].ModSpeed(-60);
        
        if (!IsUnitDead(u)) {
            buf = Buff.cast(u, u, BUFF_ID);
            buf.bd.tick = -1;
            buf.bd.interval = 10;
            UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
            buf.bd.r0 = 0.3;
            if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_WEAPON, buf, "weapon");}
            //if (buf.bd.e1 == 0) {buf.bd.e1 = BuffEffect.create(ART_WEAPON, buf, "weapon, right");}
            buf.bd.boe = onEffect;
            buf.bd.bor = onRemove;
            buf.run();
        }

        SetPlayerAbilityAvailable(p, SIDGARROTE, false);
        SetPlayerAbilityAvailable(p, SIDAMBUSH, false);        
        SetPlayerAbilityAvailable(p, SIDEVISCERATE, true);
        SetPlayerAbilityAvailable(p, SIDASSAULT, true);
        premise[GetPlayerId(p)] = CreateUnit(p, PREMISE_ID, DUMMY_X, DUMMY_Y, 0.0);
        p = null;
    }
    
    function stealth(unit u) {
        player p = GetOwningPlayer(u);
        if (IsInCombat()) {
            MobList.clearForAll(u);
        }        

        SetPlayerAbilityAvailable(p, SIDEVISCERATE, false);
        SetPlayerAbilityAvailable(p, SIDASSAULT, false);
        SetPlayerAbilityAvailable(p, SIDGARROTE, true);
        SetPlayerAbilityAvailable(p, SIDAMBUSH, true);
        
        UnitAddAbility(u, SIDAPIV);
        UnitProp[u].ModSpeed(60);
        AddTimedEffect.atCoord(ART, GetUnitX(u), GetUnitY(u), 1.0);
        
        KillUnit(premise[GetPlayerId(p)]);
        premise[GetPlayerId(p)] = null;
        
        p = null;
    }

    function onCast() {
        stealth(SpellEvent.CastingUnit);
    }
    
    function ruguedamaged() {
        if (GetUnitAbilityLevel(DamageResult.target, SIDAPIV) > 0 && GetUnitAbilityLevel(DamageResult.target, SIDSTEALTH) > 0) {
            BJDebugMsg("To unstealth");
            unstealth(DamageResult.target);
        }
    }
    
    function attacked() -> boolean {
        unit u = null;
        if (GetUnitAbilityLevel(GetAttacker(), SIDAPIV) > 0 && GetUnitAbilityLevel(GetAttacker(), SIDSTEALTH) > 0) {
            u = GetAttacker();
        } else if (GetUnitAbilityLevel(GetTriggerUnit(), SIDAPIV) > 0 && GetUnitAbilityLevel(GetTriggerUnit(), SIDSTEALTH) > 0) {
            u = GetTriggerUnit();
        }
        if (u != null) {
            unstealth(u);
        }
        u = null;
        return false;
    }
    
    function onCastAnySpell() {
        if (GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDAPIV) > 0 && GetUnitAbilityLevel(SpellEvent.CastingUnit, SIDSTEALTH) > 0) {
            unstealth(SpellEvent.CastingUnit);
        }
    }

    function onInit() {
        integer i;
        RegisterSpellEffectResponse(SIDSTEALTH, onCast);
        RegisterSpellEffectResponse(0, onCastAnySpell);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterDamagedEvent(ruguedamaged);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ATTACKED, function attacked);
        
        i = 0;
        while (i < NUMBER_OF_MAX_PLAYERS) {
            premise[i] = CreateUnit(Player(i), PREMISE_ID, DUMMY_X, DUMMY_Y, 0.0);
            i += 1;
        }
    }
#undef PREMISE_ID
#undef BUFF_ID
#undef ART_WEAPON
#undef ART
}
//! endzinc
