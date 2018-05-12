//! zinc
library HealedStackHoly requires Table, BuffSystem, DamageSystem {
    HandleTable ht;

    function healed() {
        integer i = 0;
        item ti;
        integer max;
        if (HealResult.wasDirect == true) {
            if (ht.exists(HealResult.target) && ht[HealResult.target] > 0) {
                while (i < 6) {
                    ti = UnitItemInSlot(HealResult.target, i);
                    if (ti != null && GetItemTypeId(ti) == ITID_MIGHT_OF_THE_ANGEL_OF_JUSTICE) {
                        max = Rounding(ItemExAttributes.getAttributeValue(ti, IATTR_HEAL_HOLY, SCOPE_PREFIX) * (1 + ItemExAttributes.getAttributeValue(ti, IATTR_LP, SCOPE_PREFIX) * 0.33));
                        if (GetItemCharges(ti) == 0) {
                            SetItemCharges(ti, 2);
                        } else if (GetItemCharges(ti) < max) {
                            SetItemCharges(ti, GetItemCharges(ti) + 1);
                        }
                    }
                    i += 1;
                }
                ti = null;
            }
        }
    }

    public function EquipedHealedStackHoly(unit u, integer polar) {
        if (ht.exists(u) == false) {
            ht[u] = 0;
        }
        ht[u] = ht[u] + polar;
    }

    function onInit() {
        ht = HandleTable.create();
        RegisterHealedEvent(healed);
    }

}
//! endzinc
