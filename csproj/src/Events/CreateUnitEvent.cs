public struct CreateUnitEventData
{
    public unit u;
}

public class CreateUnitEvent : EventBase<CreateUnitEventData>
{
    public static CreateUnitEvent _instance { get; private set; } = null!;

    public static CreateUnitEvent Instance
    {
        get
        {
            _instance ??= new CreateUnitEvent();
            return _instance;
        }
    }

    public CreateUnitEvent()
    {
        var mapRect = CreateRegion();
        RegionAddRect(mapRect, bj_mapInitialPlayableArea);
        var trigger = CreateTrigger();
        TriggerRegisterEnterRegion(trigger, mapRect, Filter(() => !Helper.IsUnitDummy(GetFilterUnit())));
        TriggerAddAction(trigger, () =>
        {
            ResponseCall(new CreateUnitEventData { u = GetTriggerUnit() });
        });
    }
}