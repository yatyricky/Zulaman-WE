//! zinc
library ArthassCorruption requires IntegerPool {
    HandleTable processing;

    public function RefreshArthassCorruption(unit u) {
        integer i = 0;
        integer itid;
        integer repid;
        real x, y;
        IntegerPool ip;
        item tmpi = null;
        if (!processing.exists(u)) {
            processing[u] = 1;
            ip = IntegerPool.create();
            while (i < 6) {
                tmpi = UnitItemInSlot(u, i);
                itid = GetItemTypeId(tmpi);
                if (itid == ITID_DETERMINATION_OF_VENGEANCE || itid == ITID_DETERMINATION_OF_VENGEANCE1) {
                    ip.add(1, 1);
                } else if (itid == ITID_STRATHOLME_TRAGEDY || itid == ITID_STRATHOLME_TRAGEDY1) {
                    ip.add(2, 1);
                } else if (itid == ITID_PATRICIDE || itid == ITID_PATRICIDE1 || itid == ITID_PATRICIDE2) {
                    ip.add(3, 1);
                } else if (itid == ITID_FROSTMOURNE || itid == ITID_FROSTMOURNE1 || itid == ITID_FROSTMOURNE2) {
                    ip.add(4, 1);
                }
                i += 1;
            }
            x = GetUnitX(u);
            y = GetUnitY(u);
            i = 0;
            while (i < 6) {
                tmpi = UnitItemInSlot(u, i);
                itid = GetItemTypeId(tmpi);
                if (itid == ITID_DETERMINATION_OF_VENGEANCE) { // MARK
                    if (ip.size > 1) {
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(ITID_DETERMINATION_OF_VENGEANCE1, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_DETERMINATION_OF_VENGEANCE1) { // MARK
                    if (ip.size < 2) {
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(ITID_DETERMINATION_OF_VENGEANCE, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_STRATHOLME_TRAGEDY) { // MARK
                    if (ip.size > 2) {
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(ITID_STRATHOLME_TRAGEDY1, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_STRATHOLME_TRAGEDY1) { // MARK
                    if (ip.size < 3) {
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(ITID_STRATHOLME_TRAGEDY, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_PATRICIDE) { // MARK
                    if (ip.size > 1) {
                        if (ip.size < 4) {
                            repid = ITID_PATRICIDE1;
                        } else {
                            repid = ITID_PATRICIDE2;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_PATRICIDE1) { // MARK
                    if (ip.size < 2 || ip.size > 3) {
                        if (ip.size < 2) {
                            repid = ITID_PATRICIDE;
                        } else {
                            repid = ITID_PATRICIDE2;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_PATRICIDE2) { // MARK
                    if (ip.size < 4) {
                        if (ip.size < 2) {
                            repid = ITID_PATRICIDE;
                        } else {
                            repid = ITID_PATRICIDE1;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_FROSTMOURNE) { // MARK
                    if (ip.size > 1) {
                        if (ip.size < 4) {
                            repid = ITID_FROSTMOURNE1;
                        } else {
                            repid = ITID_FROSTMOURNE2;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_FROSTMOURNE1) { // MARK
                    if (ip.size != 3) {
                        if (ip.size < 3) {
                            repid = ITID_FROSTMOURNE;
                        } else {
                            repid = ITID_FROSTMOURNE2;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                } else if (itid == ITID_FROSTMOURNE2) { // MARK
                    if (ip.size < 4) {
                        if (ip.size < 3) {
                            repid = ITID_FROSTMOURNE;
                        } else {
                            repid = ITID_FROSTMOURNE1;
                        }
                        UnitRemoveItem(u, tmpi);
                        RemoveItem(tmpi);
                        tmpi = CreateItem(repid, x, y);
                        IssueTargetOrderById(u, OID_SMART, tmpi);
                        UnitDropItemSlot(u, tmpi, i);
                    }
                }
                i += 1;
            }
            ip.destroy();
            tmpi = null;
            processing.flush(u);
        }
    }
    
    function onInit() {
        processing = HandleTable.create();
    }
}
//! endzinc
