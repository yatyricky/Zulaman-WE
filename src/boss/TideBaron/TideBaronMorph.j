//! zinc
library TideBaronMorph requires BuffSystem, SpellEvent, AggroSystem {
    function onCast() -> boolean {
        unit u = GetTriggerUnit();
        integer iid = GetIssuedOrderId();
        if ((GetUnitTypeId(u) == UTIDTIDEBARON || GetUnitTypeId(u) == UTIDTIDEBARONWATER) && (iid == OID_BEARFORM || iid == OID_UNBEARFORM)) {
            AddTimedEffect.atCoord(ART_WATER, GetUnitX(u), GetUnitY(u), 0.3);
            if (IsInCombat()) {
                AggroList[u].reset();
            }
			BuffSlot[u].removeAllBuff();
            
            if (iid == OID_BEARFORM) {
                UnitProp[u].spellTaken += 0.5;
            } else {
                UnitProp[u].spellTaken -= 0.5;
            }
        }
        u = null;
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_UNIT_ISSUED_ORDER, function onCast);
    }
}
//! endzinc
