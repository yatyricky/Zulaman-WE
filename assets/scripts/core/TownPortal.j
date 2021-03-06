//! zinc
library TownPortal requires DebugExporter, AggroSystem {
    public constant integer NUM_PORTALS = 8;
    unit portals[];
    boolean activated[];

    public function AddPortal(unit portal) {
        if (RectContainsUnit(gg_rct_ActivatePortal0, portal)) {
            portals[0] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal1, portal)) {
            portals[1] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal2, portal)) {
            portals[2] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal3, portal)) {
            portals[3] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal4, portal)) {
            portals[4] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal5, portal)) {
            portals[5] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal6, portal)) {
            portals[6] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal7, portal)) {
            portals[7] = portal;
        }
    }

    function activate(integer itid, integer id) {
        integer i = 0;
        activated[id] = true;
        AddUnitAnimationProperties(portals[id], "Work", true);
        AddTimedEffect.atPos(ART_TOME_OF_RETRAINING_CASTER, GetUnitX(portals[id]), GetUnitY(portals[id]), GetUnitZ(portals[id]), 1.0, 2.0);
        while (i < NUM_PORTALS) {
            AddItemToStock(portals[i], itid, 1, 1);
            i += 1;
        }
    }

    function usedTownPortal() -> boolean {
        item it = GetManipulatedItem();
        integer itid = GetItemTypeId(it);
        unit u = GetTriggerUnit();
        player p = GetOwningPlayer(u);
        if (itid == ITID_PORTAL_0) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, 5300, -12266);
                PanCameraToTimedForPlayer(p, 5300, -12266, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_1) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, -5989, -12197);
                PanCameraToTimedForPlayer(p, -5989, -12197, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_2) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, -1210, -5429);
                PanCameraToTimedForPlayer(p, -1210, -5429, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_3) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, 3074, -4825);
                PanCameraToTimedForPlayer(p, 3074, -4825, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_4) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, 6479, -1116);
                PanCameraToTimedForPlayer(p, 6479, -1116, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_5) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, 7275, 8812);
                PanCameraToTimedForPlayer(p, 7275, 8812, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_6) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, -7211, 8782);
                PanCameraToTimedForPlayer(p, -7211, 8782, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_7) {
            if (IsInCombat() == false) {
                SetUnitPosition(u, -2195, 3644);
                PanCameraToTimedForPlayer(p, -2195, 3644, 1.00);
                AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            }
            SelectUnitForPlayerSingle(u, p);
            RemoveItem(it);
        }
        it = null;
        u = null;
        p = null;
        return false;
    }

    function onInit() {
        trigger trg0;
        trigger trg1;
        trigger trg2;
        trigger trg3;
        trigger trg4;
        trigger trg5;
        trigger trg6;
        trigger trg7;
        integer i = 0;
        TriggerAnyUnit(EVENT_PLAYER_UNIT_PICKUP_ITEM, function usedTownPortal);
        while (i < NUM_PORTALS) {
            activated[i] = false;
            i += 1;
        }
        trg0 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg0, gg_rct_ActivatePortal0);
        TriggerAddCondition(trg0, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[0] == false) {
                activate(ITID_PORTAL_0, 0);
            }
            return false;
        }));
        trg1 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg1, gg_rct_ActivatePortal1);
        TriggerAddCondition(trg1, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[1] == false) {
                activate(ITID_PORTAL_1, 1);
            }
            return false;
        }));
        trg2 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg2, gg_rct_ActivatePortal2);
        TriggerAddCondition(trg2, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[2] == false) {
                activate(ITID_PORTAL_2, 2);
            }
            return false;
        }));
        trg3 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg3, gg_rct_ActivatePortal3);
        TriggerAddCondition(trg3, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[3] == false) {
                activate(ITID_PORTAL_3, 3);
            }
            return false;
        }));
        trg4 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg4, gg_rct_ActivatePortal4);
        TriggerAddCondition(trg4, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[4] == false) {
                activate(ITID_PORTAL_4, 4);
            }
            return false;
        }));
        trg5 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg5, gg_rct_ActivatePortal5);
        TriggerAddCondition(trg5, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[5] == false) {
                activate(ITID_PORTAL_5, 5);
            }
            return false;
        }));
        trg6 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg6, gg_rct_ActivatePortal6);
        TriggerAddCondition(trg6, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[6] == false) {
                activate(ITID_PORTAL_6, 6);
            }
            return false;
        }));
        trg7 = CreateTrigger();
        TriggerRegisterEnterRectSimple(trg7, gg_rct_ActivatePortal7);
        TriggerAddCondition(trg7, Condition(function() -> boolean {
            if (GetPidofu(GetTriggerUnit()) < NUMBER_OF_MAX_PLAYERS && activated[7] == false) {
                activate(ITID_PORTAL_7, 7);
            }
            return false;
        }));
        trg0 = null;
        trg1 = null;
        trg2 = null;
        trg3 = null;
        trg4 = null;
        trg5 = null;
        trg6 = null;
        trg7 = null;

        TimerStart(CreateTimer(), 0.13, false, function() {
            group g;
            unit tu;
            DestroyTimer(GetExpiredTimer());

            g = NewGroup();
            GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, null);
            tu = FirstOfGroup(g);
            while (tu != null) {
                if (GetUnitTypeId(tu) == UTID_TOWN_PORTAL) {
                    AddPortal(tu);
                }
                GroupRemoveUnit(g, tu);
                tu = FirstOfGroup(g);
            }
            ReleaseGroup(g);
            g = null;
            tu = null;
        });
    }
}
//! endzinc
