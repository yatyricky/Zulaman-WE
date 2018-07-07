//! zinc
library ArthassCorruption requires DamageDeathCoil {

    struct ArthassCorruption {
        static HandleTable ht;
        unit u;
        integer pieces;
        boolean hasDeathCoil, hasAttributes, hasUnholyAura;

        method destroy() {
            thistype.ht.flush(this.u);
            this.u = null;
            this.deallocate();
        }

        method equipAttributes(boolean flag) {
            UnitProp up;
            if (flag == true) {
                if (this.hasAttributes == false) {
                    up = UnitProp.inst(this.u, SCOPE_PREFIX);
                    up.ModStr(20);
                    up.ModAgi(20);
                    up.ModInt(20);
                    this.hasAttributes = true;
                }
            } else {
                if (this.hasAttributes == true) {
                    up = UnitProp.inst(this.u, SCOPE_PREFIX);
                    up.ModStr(-20);
                    up.ModAgi(-20);
                    up.ModInt(-20);
                    this.hasAttributes = false;
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
                this.hasDeathCoil = false;
                this.hasAttributes = false;
                this.hasUnholyAura = false;
                thistype.ht[u] = this;
            }
            if (pieces == 0) {
                this.equipAttributes(false);
                this.destroy();
            } else {
                this.pieces = pieces;
                if (this.pieces == 4) {
                    this.equipAttributes(true);
                    if (this.hasUnholyAura == false) {
                        EquipedUnholyAura(this.u, 1);
                        this.hasUnholyAura = true;
                    }
                } else {
                    this.equipAttributes(false);
                    if (this.hasUnholyAura == true) {
                        EquipedUnholyAura(this.u, -1);
                        this.hasUnholyAura = false;
                    }
                }
                if (this.pieces >= 3) {
                    if (this.hasDeathCoil == false) {
                        EquipedDamageDeathCoil(this.u, 1);
                        this.hasDeathCoil = true;
                    }
                } else {
                    if (this.hasDeathCoil == true) {
                        EquipedDamageDeathCoil(this.u, -1);
                        this.hasDeathCoil = false;
                    }
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
        string setInfo = "|n|cff" + COLOR_ITEM_SET_NAME + "Corruption of Arthas|r|n";
        while (ii < 6) {
            ti = UnitItemInSlot(dt.u0, ii);
            if (ti != null) {
                itid = GetItemTypeId(ti);
                if (itid == ITID_DETERMINATION_OF_VENGEANCE || itid == ITID_STRATHOLME_TRAGEDY || itid == ITID_PATRICIDE || itid == ITID_FROSTMOURNE) {
                    if (list.indexOfObject(itid) == -1) {
                        list.push(itid);
                    }
                }
            }
            ii += 1;
        }
        ArthassCorruption.equiped(dt.u0, list.count());
        // set text
        // if (list.indexOfObject(ITID_DETERMINATION_OF_VENGEANCE) == -1) {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        // } else {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        // }
        // setInfo += "Determination of Vengeance" + COLOR_R + "|n";

        // if (list.indexOfObject(ITID_STRATHOLME_TRAGEDY) == -1) {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        // } else {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        // }
        // setInfo += "Stratholme Tragedy" + COLOR_R + "|n";

        // if (list.indexOfObject(ITID_PATRICIDE) == -1) {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        // } else {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        // }
        // setInfo += "Patricide" + COLOR_R + "|n";

        // if (list.indexOfObject(ITID_FROSTMOURNE) == -1) {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        // } else {
        //     setInfo += COLOR_CFF + COLOR_ITEM_SET_ACQUIRED;
        // }
        // setInfo += "FrostMourne" + COLOR_R + "|n";
        if (list.count() >= 3) {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_NAME;
        } else {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        }
        setInfo += "(3) Set:|n";
        setInfo += "On Attack: 15% chance to cast Death Coil|r|n";
        if (list.count() >= 4) {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_NAME;
        } else {
            setInfo += COLOR_CFF + COLOR_ITEM_SET_MISSING;
        }
        setInfo += "(4) Set:|n";
        setInfo += "+20 All stats|n";
        setInfo += "Grant Aura of Unholy: All allies within 600 yards regen 20 HP per second|r";
        ii = 0;
        while (ii < 6) {
            ti = UnitItemInSlot(dt.u0, ii);
            if (ti != null) {
                itid = GetItemTypeId(ti);
                if (itid == ITID_DETERMINATION_OF_VENGEANCE || itid == ITID_STRATHOLME_TRAGEDY || itid == ITID_PATRICIDE || itid == ITID_FROSTMOURNE) {
                    // BlzSetItemExtendedTooltip(ti, ItemExAttributes.inst(ti, SCOPE_PREFIX).forgeUbertip() + setInfo);
                }
            }
            ii += 1;
        }
        list.destroy();
        ti = null;
    }

    public function EquipedArthassCorruption(unit u, integer polar) {
        DelayTask.create(postEvaluateSet, 0.001).u0 = u;
    }

}
//! endzinc
