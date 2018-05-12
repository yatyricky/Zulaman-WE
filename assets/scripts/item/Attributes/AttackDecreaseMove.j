//! zinc
library AttackDecreaseMove requires Table, BuffSystem, DamageSystem {
    HandleTable ht;

    function onEffect(Buff buf) {}

    function onRemove(Buff buf) {
        UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "onRemove").ModSpeed(buf.bd.i1);
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
                        amt += ItemExAttributes.getAttributeValue(ti, IATTR_ATK_DMS, SCOPE_PREFIX + "damaged") * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX + "damaged2") * 0.2);
                    }
                    i += 1;
                }
                ti = null;
                // take effect
                buf = Buff.cast(DamageResult.source, DamageResult.target, BID_DECREASE_MOVESPEED);
                buf.bd.tick = -1;
                buf.bd.interval = 3;
                if (buf.bd.e0 == 0) {
                    buf.bd.e0 = BuffEffect.create(ART_SLOW, buf, "origin");
                }
                tup = UnitProp.inst(buf.bd.target, SCOPE_PREFIX + "damaged3");
                if (buf.bd.i0 == 0) {
                    buf.bd.i0 = 17;
                    buf.bd.i1 = Rounding(I2R(tup.Speed()) * amt);
                    tup.ModSpeed(0 - buf.bd.i1);
                } else {
                    newVal = Rounding(I2R(tup.Speed() + buf.bd.i1) * amt);
                    if (newVal > buf.bd.i1) {
                        tup.ModSpeed(buf.bd.i1 - newVal);
                        buf.bd.i1 = newVal;
                    }
                }
                buf.bd.boe = onEffect;
                buf.bd.bor = onRemove;
                buf.run();
            }
        }
    }

    public function EquipedAttackDecreaseMoveSpeed(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterDamagedEvent(damaged);
        BuffType.register(BID_DECREASE_MOVESPEED, BUFF_MAGE, BUFF_NEG);
    }

}
//! endzinc
