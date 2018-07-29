//! zinc
library AttackAmplifiedDamage requires BuffSystem, DamageSystem {
    HandleTable ht;

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").damageTaken -= buf.bd.r0;
    }
    
    function damaged() {
        Buff buf;
        real amp;
        if (DamageResult.isHit == false) return;
        if (DamageResult.abilityName != DAMAGE_NAME_MELEE) return;
        if (ht.exists(DamageResult.source) == false) return;
        if (ht[DamageResult.source] <= 0) return;

        amp = ItemExAttributes.getUnitAttrVal(DamageResult.source, IATTR_ATK_AMP, SCOPE_PREFIX);
        buf = Buff.cast(DamageResult.source, DamageResult.target, BID_AMPLIFIED_DAMAGE);
        buf.bd.tick = -1;
        buf.bd.interval = 3;
        if (buf.bd.e0 == 0) {buf.bd.e0 = BuffEffect.create(ART_BOTTLE_IMPACT, buf, "chest");}
        if (buf.bd.r0 < amp) {
            UnitProp.inst(buf.bd.target, SCOPE_PREFIX).damageTaken += (amp - buf.bd.r0);
            buf.bd.r0 = amp;
        }
        buf.bd.boe = Buff.noEffect;
        buf.bd.bor = onRemove;
        buf.run();
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
