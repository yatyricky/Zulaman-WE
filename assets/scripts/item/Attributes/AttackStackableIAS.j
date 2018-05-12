//! zinc
library AttackStackableIAS requires Table, BuffSystem, DamageSystem {
    HandleTable ht;

    function onEffect(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(buf.bd.i0);
    }

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX).ModAttackSpeed(0 - buf.bd.i1);
    }
    
    function damaged() {
        integer i = 0;
        item ti;
        real amt;
        integer max;
        UnitProp tup;
        Buff buf;
        if (DamageResult.isHit == true && DamageResult.abilityName == DAMAGE_NAME_MELEE) {
            if (ht.exists(DamageResult.source) && ht[DamageResult.source] > 0) {
                amt = 0;
                while (i < 6) {
                    ti = UnitItemInSlot(DamageResult.source, i);
                    if (ti != null) {
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_CTHUN, SCOPE_PREFIX + "damaged") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "damaged2"));
                    }
                    i += 1;
                }
                ti = null;
                // take effect
                buf = Buff.cast(DamageResult.source, DamageResult.source, BID_CTHUNS_DERANGEMENT_IAS);
                buf.bd.tick = -1;
                buf.bd.interval = 3;
                max = Rounding(amt * 100);
                tup = UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "damaged3");
                if (buf.bd.i1 < max) {
                    buf.bd.i0 = 1;
                } else {
                    buf.bd.i0 = 0;
                }
                buf.bd.i1 += buf.bd.i0;
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedAttackStackableIAS(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_CTHUNS_DERANGEMENT_IAS, BUFF_PHYX, BUFF_POS);
    }

}
//! endzinc
