//! zinc
library AttackDecreaseHealed requires Table, BuffSystem, DamageSystem {
    HandleTable ht;

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").healTaken += buf.bd.r0;
    }
    
    function damaged() {
        integer i = 0;
        item ti;
        real amt;
        UnitProp tup;
        Buff buf;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                amt = 0;
                while (i < 6) {
                    ti = UnitItemInSlot(DamageResult.source, i);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_MORTAL, SCOPE_PREFIX + "damaged") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "damaged2") * 0.7);
                    }
                    i += 1;
                }
                ti = null;
                // take effect
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_DECREASE_HEALTAKEN);
                buf.bd.tick = -1;
                buf.bd.interval = 3;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_CRIPPLE_TARGET, buf, "origin");
                }
                tup = UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "damaged3");
                if (buf.bd.i0 == 0) {
                    buf.bd.i0 = 17;
                    buf.bd.r0 = amt;
                    tup.healTaken -= buf.bd.r0;
                } else {
                    if (amt > buf.bd.r0) {
                        tup.healTaken -= (amt - buf.bd.r0);
                        buf.bd.r0 = amt;
                    }
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedAttackDecreaseHealed(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_DECREASE_HEALTAKEN, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
