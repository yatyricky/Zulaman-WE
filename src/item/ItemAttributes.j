//! zinc
library ItemAttributes requires UnitProperty, Table {
    public type ItemPropModType extends function(unit, item, integer);
    //public HandleTable itemInst;
    Table ItemAttributes;
    /*
    struct DelayedRmIt {
        timer tm;
        item it;
        
        method destroy() {
            ReleaseTimer(this.tm);
            this.tm = null;
            this.it = null;
            this.deallocate();
        }
    }
    
    function delayedRemoveItemExe() {
        DelayedRmIt dt = DelayedRmIt(GetTimerData(GetExpiredTimer()));
        RemoveItem(dt.it);
        dt.destroy();
    }
    
    public function DelayedRemoveItem(item it) {
        DelayedRmIt dt = DelayedRmIt.create();
        dt.tm = NewTimer();
        SetTimerData(dt.tm, dt);
        dt.it = it;
        TimerStart(dt.tm, 0.01, false, function delayedRemoveItemExe);
    }*/
    
    public function RegisterItemPropMod(integer itid, ItemPropModType act) {
        if (ItemAttributes.exists(itid)) {
            BJDebugMsg(SCOPE_PREFIX+":>|cffff0000Double registering item property action.|r");
        } else {
            ItemAttributes[itid] = act;
        }
    }

    function ItemAffixEffect(unit u, item it, integer polar) {
        ItemAffix data = ItemAffix.inst(it, "ItemAttributes.ItemAffixEffect");
        UnitProp up = UnitProp.inst(u, SCOPE_PREFIX);
        integer i;
        while (data != 0) {
            i = 0;
            while (i < data.attributeN) {
                if (data.attribute[i] == AFFIX_TYPE_STR) {
                    up.ModStr(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_AGI) {
                    up.ModAgi(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_INT) {
                    up.ModInt(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_HP) {
                    up.ModLife(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_AP) {
                    up.ModAP(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_CRIT) {
                    up.attackCrit += data.value[i] * polar;
                } else if (data.attribute[i] == AFFIX_TYPE_IAS) {
                    up.ModAttackSpeed(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SP) {
                    up.spellPower += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SCRIT) {
                    up.spellCrit += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_SHASTE) {
                    up.spellHaste += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_MREGEN) {
                    up.manaRegen += (data.value[i] * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_DEF) {
                    up.ModArmor(Rounding(data.value[i]) * polar);
                } else if (data.attribute[i] == AFFIX_TYPE_DODGE) {
                    up.dodge += (data.value[i] * polar);
                }
                i += 1;
            }
            data = data.next;
        }
    }

    function itemon() -> boolean {
        item it = GetManipulatedItem();
        integer itid = GetItemTypeId(it);
        integer i;
        item tmpi;
        unit u = GetTriggerUnit();
        if (ItemAttributes.exists(itid)) {
            ItemPropModType(ItemAttributes[itid]).evaluate(u, it, 1);
            ItemAffixEffect(u, it, 1);
            //if (!itemInst.exists())
        }
        // stack charges
        if (IsItemTypeConsumable(itid)) {
            i = 0;
            while (i < 6) {
                tmpi = UnitItemInSlot(u, i);
                if (GetItemTypeId(tmpi) == itid && GetHandleId(tmpi) != GetHandleId(it)) {
                    SetItemCharges(tmpi, GetItemCharges(tmpi) + GetItemCharges(it));
                    RemoveItem(it);
                    i += 6;
                }
                i += 1;
                tmpi = null;
            }
        }
        u = null;
        it = null;
        return false;
    }
    
    function itemoff() -> boolean {
        integer itid = GetItemTypeId(GetManipulatedItem());
        if (ItemAttributes.exists(itid)) {
            ItemPropModType(ItemAttributes[itid]).evaluate(GetTriggerUnit(), GetManipulatedItem(), -1);
            ItemAffixEffect(GetTriggerUnit(), GetManipulatedItem(), -1);
        }
        return false;
    }
    

    function onInit() {
        ItemAttributes = Table.create();
        //itemInst = HandleTable.create();
        
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function itemon);
        TriggerAnyUnit(EVENT_PLAYER_UNIT_DROP_ITEM, function itemoff);
    }
}
//! endzinc
