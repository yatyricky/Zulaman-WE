//! zinc
library AttackAmplifiedDamage requires BuffSystem, DamageSystem {
    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").damageTaken += buf.bd.r0;
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").damageTaken -= buf.bd.r0;
    }
    
    function damaged() {
        Buff buf;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_AMPLIFIED_DAMAGE);
                buf.bd.tick = -1;
                buf.bd.interval = 3;
                if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BOTTLE_IMPACT, buf, "chest");}
                UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken -= buf.bd.r0;
                buf.bd.r0 = ItemExAttributes.getUnitAttributeValue(DamageResult.source, IATTR_ATK_AMP, 0.1, SCOPE_PREFIX);
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedAttackAmplifiedDamage(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_AMPLIFIED_DAMAGE, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
