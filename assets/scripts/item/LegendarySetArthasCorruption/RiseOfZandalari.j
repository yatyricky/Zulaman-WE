//! zinc
library RiseOfZandalari {

    struct RiseOfZandalari {
        static HandleTable ht;
        unit u;
        integer pieces;
        boolean hasRegen, hasHP, hasMDR;

        method destroy() {
            thistype.ht.flush(this.u);
            this.u = null;
            this.deallocate();
        }

        method equipRegen(boolean flag) {
            if (flag == true) {
                if (this.hasRegen == false) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).lifeRegen += 60;
                    this.hasRegen = true;
                }
            } else {
                if (this.hasRegen == true) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).lifeRegen -= 60;
                    this.hasRegen = false;
                }
            }
        }

        method equipHP(boolean flag) {
            if (flag == true) {
                if (this.hasHP == false) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).ModLife(500);
                    this.hasHP = true;
                }
            } else {
                if (this.hasHP == true) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).ModLife(-500);
                    this.hasHP = false;
                }
            }
        }

        method equipMDR(boolean flag) {
            if (flag == true) {
                if (this.hasMDR == false) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).spellTaken -= 0.15;
                    this.hasMDR = true;
                }
            } else {
                if (this.hasMDR == true) {
                    UnitProp.inst(this.u, SCOPE_PREFIX).spellTaken += 0.15;
                    this.hasMDR = false;
                }
            }
        }

        static method equiped(unit u, integer pieces) {
            thistype this;
            if (thistype.ht.exists(u) == true) {
                this = thistype.ht[u];
            } else {
                this = thistype.allocate();
                this.u = u;
                this.pieces = 0;
                this.hasRegen = false;
                this.hasHP = false;
                this.hasMDR = false;
                thistype.ht[u] = this;
            }
            if (pieces == 0) {
                this.destroy();
            } else {
                this.pieces = pieces;
                if (this.pieces >= 5) {
                    this.equipMDR(true);
                } else {
                    this.equipMDR(false);
                }
                if (this.pieces >= 4) {
                    this.equipHP(true);
                } else {
                    this.equipHP(false);
                }
                if (this.pieces >= 3) {
                    this.equipRegen(true);
                } else {
                    this.equipRegen(false);
                }
            }
        }

        private static method onInit() {
            thistype.ht = HandleTable.create();
        }
    }

    function postEvaluateSet(DelayTask dt) {
        ListObject list = ListObject.create();
        item ti;
        integer ii = 0;
        integer itid;
        string setInfo = "|n|cff" + COLOR_ITEM_SET_NAME + "Rise of Zandalari|r|n";
        while (ii < 6) {
            ti = UnitItemInSlot(dt.u0, ii);
            if (ti != null) {
                itid = GetItemTypeId(ti);
                if (itid == ITID_BULWARK_OF_THE_AMANI_EMPIRE || itid == ITID_SHINING_JEWEL_OF_TANARIS || itid == ITID_DRAKKARI_DECAPITATOR || itid == ITID_GURUBASHI_VOODOO_VIALS || itid == ITID_ZULS_STAFF) {
                    if (list.indexOfObject(itid) == -1) {
                        list.push(itid);
                    }
                }
            }
            ii += 1;
        }
        RiseOfZandalari.equiped(dt.u0, list.count());
        // set text
        if (list.count() >= 3) {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        } else {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        }
        setInfo += "(3 Set) Regens 60 HP per second|r|n";
        if (list.count() >= 4) {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        } else {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        }
        setInfo += "(4 Set) +500 Max HP|r|n";
        if (list.count() >= 5) {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        } else {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        }
        setInfo += "(5 Set) -15% magical damage taken|r";
        ii = 0;
        while (ii < 6) {
            ti = UnitItemInSlot(dt.u0, ii);
            if (ti != null) {
                itid = GetItemTypeId(ti);
                if (itid == ITID_BULWARK_OF_THE_AMANI_EMPIRE || itid == ITID_SHINING_JEWEL_OF_TANARIS || itid == ITID_DRAKKARI_DECAPITATOR || itid == ITID_GURUBASHI_VOODOO_VIALS || itid == ITID_ZULS_STAFF) {
                    BlzSetItemExtendedTooltip(ti, ItemExAttributes.inst(ti, SCOPE_PREFIX).forgeUbertip() + setInfo);
                }
            }
            ii += 1;
        }
        list.destroy();
        ti = null;
    }

    public function EquipedRiseOfZandalari(unit u, integer polar) {
        DelayTask.create(postEvaluateSet, 0.001).u0 = u;
    }

}
//! endzinc
