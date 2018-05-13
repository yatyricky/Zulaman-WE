//! zinc
library AttackDecreaseAS requires Table, BuffSystem, DamageSystem {
    HandleTable ht;

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").ModAttackSpeed(buf.bd.i1);
    }
    
    function damaged() {
        integer i = 0;
        item ti;
        real amt;
        UnitProp tup;
        integer newVal;
        Buff buf;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                amt = 0;
                while (i < 6) {
                    ti = UnitItemInSlot(DamageResult.source, i);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_DAS, SCOPE_PREFIX + "damaged") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "damaged2") * 0.2);
                    }
                    i += 1;
                }
                ti = null;
                // take effect
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_DECREASE_ATTACKSPEED);
                buf.bd.tick = -1;
                buf.bd.interval = 3;
                tup = UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "damaged3");
                if (buf.bd.i0 == 0) {
                    buf.bd.i0 = 17;
                    buf.bd.i1 = Rounding(amt * 100);
                    tup.ModAttackSpeed(0 - buf.bd.i1);
                } else {
                    newVal = Rounding(amt * 100);
                    if (newVal > buf.bd.i1) {
                        tup.ModAttackSpeed(buf.bd.i1 - newVal);
                        buf.bd.i1 = newVal;
                    }
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedAttackDecreaseAttackSpeed(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_DECREASE_ATTACKSPEED, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc