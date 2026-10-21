public struct UnitStatEventData
{
    public unit target;
    public StatId statId;
    public StatsComponent comp;
}

public class UnitStatEvent : EventBase<UnitStatEventData>
{
    public static UnitStatEvent _instance { get; private set; } = null!;

    public static UnitStatEvent Instance
    {
        get
        {
            _instance ??= new UnitStatEvent();
            return _instance;
        }
    }

    public UnitStatEvent()
    {
        // ResponseCall(data);
    }
}
