//! zinc
library TownPortal requires DebugExporter {
    public constant integer NUM_PORTALS = 3;
    unit portals[];
    boolean activated[];

    public function AddPortal(unit portal) {
        if (RectContainsUnit(gg_rct_ActivatePortal0, portal)) {
            portals[0] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal1, portal)) {
            portals[1] = portal;
        } else if (RectContainsUnit(gg_rct_ActivatePortal2, portal)) {
            portals[2] = portal;
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
            SetUnitPosition(u, 5300, -12266);
            PanCameraToTimedForPlayer(p, 5300, -12266, 1.00);
            AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_1) {
            SetUnitPosition(u, -5989, -12197);
            PanCameraToTimedForPlayer(p, -5989, -12197, 1.00);
            AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
            RemoveItem(it);
        }
        if (itid == ITID_PORTAL_2) {
            SetUnitPosition(u, -1210, -5429);
            PanCameraToTimedForPlayer(p, -1210, -5429, 1.00);
            AddTimedEffect.atUnit(ART_MASS_TELEPORT_TARGET, u, "origin", 0.5);
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
        trg0 = null;
        trg1 = null;
        trg2 = null;
    }
}
//! endzinc
