//! zinc
library BearForm requires NefUnion {
    function launch() -> boolean {
        if (GetIssuedOrderId() == OID_BEARFORM) {
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_LACERATE, true);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_MANGLE, true);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_MAUL, true);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_BASH, true);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_CHALLENGINGROAR, true);
        } else if (GetIssuedOrderId() == OID_UNBEARFORM) {
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_LACERATE, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_MANGLE, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_MAUL, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_BASH, false);
            SetPlayerAbilityAvailable(GetOwningPlayer(GetTriggerUnit()), AID_CHALLENGINGROAR, false);
        }
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function launch);
    }
}
//! endzinc
