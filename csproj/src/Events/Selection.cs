using StdLib;

/// <summary>
/// 每个玩家当前选中的单位(等价旧图 ZAMCore.j 的 PlayerSelection 数组)。
/// 命令等本地逻辑用 PlayerSelection[GetPlayerId(GetLocalPlayer())] 取选中单位。
/// </summary>
public class Selection
{
    public static Dictionary<int, unit> PlayerSelection = new();

    public static void Init()
    {
        var onSelect = CreateTrigger();
        var onDeselect = CreateTrigger();
        var i = 0;
        while (i < bj_MAX_PLAYERS)
        {
            TriggerRegisterPlayerUnitEvent(onSelect, Player(i), EVENT_PLAYER_UNIT_SELECTED, null);
            TriggerRegisterPlayerUnitEvent(onDeselect, Player(i), EVENT_PLAYER_UNIT_DESELECTED, null);
            i += 1;
        }
        TriggerAddAction(onSelect, () =>
        {
            PlayerSelection[GetPlayerId(GetTriggerPlayer())] = GetTriggerUnit();
        });
        TriggerAddAction(onDeselect, () =>
        {
            PlayerSelection.Remove(GetPlayerId(GetTriggerPlayer()));
        });
    }
}
