using System.Threading.Tasks;
using StdLib;

public struct UnitRemovedEventData
{
    public unit u;
}

/// <summary>
/// 单位移除事件:死亡 90 秒后,或经 UnitRemovedEvent.Remove() 移除时触发。
/// 注意 WC3 没有"单位被移除"的引擎事件,移除单位必须走 Remove(),直接调 native RemoveUnit 不会触发本事件。
/// </summary>
public class UnitRemovedEvent : EventBase<UnitRemovedEventData>
{
    public const int RemoveDelayMs = 90000;

    // 死亡等待中的单位 -> 令牌;令牌失配 = 等待已失效(提前 Remove、二次死亡或 handle 复用)
    private readonly Dictionary<unit, int> _pending = new();
    private int _nextToken = 0;

    public static UnitRemovedEvent _instance { get; private set; } = null!;

    public static UnitRemovedEvent Instance
    {
        get
        {
            _instance ??= new UnitRemovedEvent();
            return _instance;
        }
    }

    public UnitRemovedEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddAction(t, () => { StartDeathRemoval(GetTriggerUnit()); });
    }

    private async void StartDeathRemoval(unit u)
    {
        _nextToken += 1;
        var token = _nextToken;
        _pending[u] = token;
        await Task.Delay(RemoveDelayMs);
        var valid = _pending.TryGetValue(u, out var cur);
        if (!valid) return;
        if (cur != token) return;
        _pending.Remove(u);
        if (GetUnitTypeId(u) != 0 && IsUnitAliveBJ(u)) return;
        ResponseCall(new UnitRemovedEventData { u = u });
    }

    /// <summary>统一移除入口。移除单位必须走这里;直接调 native RemoveUnit 不会触发本事件。</summary>
    public static void Remove(unit u)
    {
        if (u == null) return;
        Instance._pending.Remove(u);
        RemoveUnit(u);
        Instance.ResponseCall(new UnitRemovedEventData { u = u });
    }

    public static bool Cancel(unit u)
    {
        if (u == null) return false;
        return Instance._pending.Remove(u);
    }
}
