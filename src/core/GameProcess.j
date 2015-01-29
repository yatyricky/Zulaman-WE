//! zinc
library GameProcess requires NefUnion {
    function startedGame() -> boolean {
        unit tu = GetSellingUnit();
        integer itid = GetItemTypeId(GetSoldItem());
        if (GetUnitTypeId(tu) == 'n00M') {
            RemoveItemFromStock(tu, itid);
        }
        if (itid == 'I01Z') {
            //ModifyGateBJ(bj_GATEOPERATION_OPEN, gg_dest_ZTsg_0215);   
            //RunSoundOnUnit(SND_DOOR, GetBuyingUnit());
        }
        return false;
    }

    function onInit() {
        TriggerAnyUnit(EVENT_PLAYER_UNIT_SELL_ITEM, function startedGame);
    }
}
//! endzinc
