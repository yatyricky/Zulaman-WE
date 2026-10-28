public struct UnitDeathEventData
{
    public unit u;
    public unit killer;
}

public class UnitDeathEvent : EventBase<UnitDeathEventData>
{
    public static UnitDeathEvent _instance { get; private set; } = null!;

    public static UnitDeathEvent Instance
    {
        get
        {
            _instance ??= new UnitDeathEvent();
            return _instance;
        }
    }

    public UnitDeathEvent()
    {
        var t = CreateTrigger();
        TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH);
        TriggerAddAction(t, () =>
        {
            ResponseCall(new UnitDeathEventData
            {
                u = GetTriggerUnit(),
                killer = GetKillingUnit(),
            });
        });
    }
}
