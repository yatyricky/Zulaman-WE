//! zinc
library HeroicStrike requires DamageSystem, SpellEvent, OrcCaptureFlag {
#define STRIKE_COST 10.0
    boolean isopen[NUMBER_OF_MAX_PLAYERS];
    integer added[NUMBER_OF_MAX_PLAYERS];
    
    public function BladeMasterIsHSOn(unit u) -> boolean {
        return isopen[GetPidofu(u)];
    }

    function onCast() -> boolean {
        unit u = GetTriggerUnit();
        integer pid = GetPlayerId(GetOwningPlayer(u));
        //print(I2S(GetIssuedOrderId()) + " : " +I2S(OrderId("innerfire")));
        if (GetUnitTypeId(u) == UTIDBLADEMASTER) {
            if (GetIssuedOrderId() == OID_IMMOLATIONON) {
                isopen[pid] = true;
                added[pid] = 7 + GetUnitAbilityLevel(u, SIDHEROICSTRIKE) * 3;
                UnitProp[u].ModAttackSpeed(added[pid]);
            } else if (GetIssuedOrderId() == OID_IMMOLATIONOFF) {
                isopen[pid] = false;
                UnitProp[u].ModAttackSpeed(0 - added[pid]);
            }
        }
        u = null;
        return false;
    }

    function ondamageresponse() {
        real scost = STRIKE_COST;
        if (isopen[GetPlayerId(GetOwningPlayer(DamageResult.source))] && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            //DamageTarget(DamageResult.source, DamageResult.target, 1000.0, SPELL_NAME, true, true, true, WEAPON_TYPE_WHOKNOWS);
            DamageResult.amount += 40 + GetUnitAbilityLevel(DamageResult.source, SIDHEROICSTRIKE) * 10;
            //DamageResult.abilityName = SpellData[SIDHEROICSTRIKE].name;
            if (HasOrcCaptureFlag(DamageResult.source)) {
                scost -= 5.0;
            }
            ModUnitMana(DamageResult.source, 0.0 - scost);
            if (GetUnitMana(DamageResult.source) < scost) {
                IssueImmediateOrderById(DamageResult.source, OID_IMMOLATIONOFF); 
            }
        }
    }
    
    function level() -> boolean {
        if (GetLearnedSkill() == SIDHEROICSTRIKE) {
            if (GetUnitAbilityLevel(GetTriggerUnit(), SIDHEROICSTRIKE) > 2) {
                UnitProp[GetTriggerUnit()].attackCrit += 0.1;
            }
        }
        return false;
    }

    function onInit() {
        integer i = 0;
        RegisterOnDamageEvent(ondamageresponse);
        while (i < NUMBER_OF_MAX_PLAYERS) {
            isopen[i] = false;
            added[i] = 0;
            i += 1;
        }
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function onCast);
        TriggerAnyUnit(EVENT_PLAYER_HERO_SKILL, function level);
    }
#undef STRIKE_COST
}
//! endzinc

