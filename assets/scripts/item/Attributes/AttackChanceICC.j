//! zinc
library AttackChanceICC requires DamageSystem, BuffSystem {

    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackCrit += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).attackCrit -= buf.bd.r0;
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;
        if (IsUnitICD(DamageResult.source, BID_CRITICAL) == true) return;
        if (GetRandomReal(0, 0.99999) > ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_CRIT, SCOPE_PREFIX)) return;

        buf = Buff.cast(DamageResult.source, DamageResult.source, BID_CRITICAL);
        buf.bd.tick = -1;
        buf.bd.interval = 5.0;
        onRemove(buf);
        buf.bd.r0 = 1;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_HEAL_SALVE, buf, "overhead");}
        buf.bd.boe = onEffect;
        buf.bd.bor = onRemove;
        buf.run();
        
        SetUnitICD(DamageResult.source, BID_CRITICAL, 10);
    }

    public function EquipedAttackChanceICC(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_CRITICAL, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
