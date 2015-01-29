//! zinc
library Ascendance requires SpellEvent, BuffSystem, DamageSystem {
#define BUFF_ID 'A03C'
#define ART "Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl"
    function onEffect(Buff buf) {
        UnitProp[buf.bd.target].damageDealt += buf.bd.r0;
        UnitProp[buf.bd.target].ModArmor(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
        UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
    }
    
    function ondamaging() {
        real dur;
        if (DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (GetUnitAbilityLevel(DamageResult.source, BUFF_ID) > 0) {
                DamageResult.wasDodgable = false;
                DamageResult.isPhyx = false;
                dur = 1.0 / (1.0 + UnitProp[DamageResult.source].AttackSpeed() / 100.0);
                AddTimedLight.atUnits("CLPB", DamageResult.source, DamageResult.target, dur);
                AddTimedEffect.atUnit(ART_IMPACT, DamageResult.target, "origin", 0.3);
            }
        }
    }
    
    function onCast() -> boolean {       
        Buff buf;
        unit u = GetTriggerUnit();
        integer iid = GetIssuedOrderId();
        real x, y, z;
        location loc;
        if ((GetUnitTypeId(u) == UTIDEARTHBINDER || GetUnitTypeId(u) == UTID_EARTH_BINDER_ASC) && (iid == SpellData[SID_ASCENDANCE].oid)) {
            //BJDebugMsg("Ascendance!");
            x = GetUnitX(u);
            y = GetUnitY(u);
            loc = Location(x, y);
            z = GetLocationZ(loc);
            AddTimedLight.atCoords3D("CLPB", x, y, z + 1800.0, x, y, z, 0.75);
            RemoveLocation(loc);
            loc = null;

            
            if (iid == SpellData[SID_ASCENDANCE].oid) {
                buf = Buff.cast(u, u, BUFF_ID);
                buf.bd.tick = -1;
                buf.bd.interval = 8.0 + 4.0 * GetUnitAbilityLevel(u, SID_ASCENDANCE);
                UnitProp[buf.bd.target].damageDealt -= buf.bd.r0;
                buf.bd.r0 = 0.3;
                UnitProp[buf.bd.target].ModArmor(0 - buf.bd.i0);
                buf.bd.i0 = 75;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART, buf, "origin");
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            } else {
                
            }
        }
        u = null;
        
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function onCast);
        BuffType.register(BUFF_ID, BUFF_PHYX, BUFF_POS);
        RegisterOnDamageEvent(ondamaging);
    }
#undef ART
#undef BUFF_ID
}
//! endzinc
