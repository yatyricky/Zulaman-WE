//! zinc
library LionHorn requires DamageSystem, BuffSystem {
    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
    }
    
    function damaged() {
        Buff buf;
        location loc;
        real x, y, z;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, BID_LION_HORN) == true) return;
        if (GetRandomReal(0, 0.999) > ItemExAttributes.getUnitAttributeValue(DamageResult.source, IATTR_ATK_LION, 0.16, SCOPE_PREFIX)) return;

        buf = Buff.cast(DamageResult.source, DamageResult.source, BID_LION_HORN);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i0);
        buf.bd.i0 = 30;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_TORNADO_TARGET, buf, "weapon");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        SetUnitICD(DamageResult.source, BID_LION_HORN, 15);
        
        x = GetUnitX(DamageResult.source);
        y = GetUnitY(DamageResult.source);
        loc = Location(x, y);
        z = GetLocationZ(loc);
        AddTimedLight.atCoords3D("CLPB", x, y, z + 4000.0, x, y, z, 0.75);
        AddTimedEffect.atUnit(ART_IMPACT, DamageResult.source, "origin", 0.2);
        RemoveLocation(loc);
        loc = null;
    }

    public function EquipedLionHorn(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_LION_HORN, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
