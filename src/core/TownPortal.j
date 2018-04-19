//! zinc
library TownPortal {
    unit portals[];
    boolean activated[];

    public function AddPortal(unit portal) {
        if (RectContainsUnit(gg_rct_ActivatePortal1, portal)) {
            portals[1] = portal;
        } else {
            portals[0] = portal;
        }
    }

    function activate(integer itid) {

    }

    function onInit() {
        trigger trg = CreateTrigger();
        count = 0;
        TriggerRegisterEnterRectSimple(trg, gg_rct_ActivatePortal1);
        TriggerAddCondition(trg, Condition(function() -> boolean {
            activate(ITID_PORTAL_1);
        }));
    }
}
//! endzinc


function Trig_WorldInit_Actions takes nothing returns nothing
    call ModifyGateBJ( bj_GATEOPERATION_OPEN, gg_dest_ZTg3_0253 )
endfunction

//===========================================================================
function InitTrig_WorldInit takes nothing returns nothing
    set gg_trg_WorldInit = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_WorldInit, gg_rct_ActivatePortal1 )
    call TriggerAddAction( gg_trg_WorldInit, function Trig_WorldInit_Actions )
endfunction

RectContainsUnit(gg_rct_ActivatePortal1, GetTriggerUnit()) == true 

