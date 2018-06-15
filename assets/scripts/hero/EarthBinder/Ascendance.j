//! zinc
library Ascendance requires SpellEvent, BuffSystem, DamageSystem {

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt += buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
    }
    
    function ondamaging() {
        real dur;
        if (DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (GetUnitAbilityLevel(DamageResult.source, BID_ELEMENTAL_ENPOWER) > 0) {
                DamageResult.wasDodgable = false;
                DamageResult.isPhyx = false;
                dur = 1.0 / (1.0 + UnitProp.inst(DamageResult.source, SCOPE_PREFIX).AttackSpeed() / 100.0);
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
        if ((GetUnitTypeId(u) == UTID_EARTH_BINDER || GetUnitTypeId(u) == UTID_EARTH_BINDER_ASC) && (iid == SpellData.inst(SID_ASCENDANCE, SCOPE_PREFIX).oid)) {
            //BJDebugMsg("Ascendance!");
            x = GetUnitX(u);
            y = GetUnitY(u);
            loc = Location(x, y);
            z = GetLocationZ(loc);
            AddTimedLight.atCoords3D("CLPB", x, y, z + 1800.0, x, y, z, 0.75);
            RemoveLocation(loc);
            loc = null;

            
            if (iid == SpellData.inst(SID_ASCENDANCE, SCOPE_PREFIX).oid) {
                buf = Buff.cast(u, u, BID_ELEMENTAL_ENPOWER);
                buf.bd.tick = -1;
                buf.bd.interval = 8.0 + 4.0 * GetUnitAbilityLevel(u, SID_ASCENDANCE);
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageDealt -= buf.bd.r0;
                buf.bd.r0 = 0.3;
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModArmor(0 - buf.bd.i0);
                buf.bd.i0 = 75;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_PurgeBuffTarget, buf, "origin");
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
        BuffType.register(BID_ELEMENTAL_ENPOWER, BUFF_PHYX, BUFF_POS);
        RegisterOnDamageEvent(ondamaging);
    }


}
//! endzinc
