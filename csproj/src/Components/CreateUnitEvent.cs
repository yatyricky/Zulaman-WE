using System;
using StdLib;

public class CreateUnitEvent : Component
{
    public static CreateUnitEvent Instance { get; private set; } = null!;
    private List<Action<unit>> _callbacks = new();

    public override void Awake()
    {
        Instance = this;

        var mapRect = CreateRegion();
        RegionAddRect(mapRect, bj_mapInitialPlayableArea);
        var trigger = CreateTrigger();
        TriggerRegisterEnterRegion(trigger, mapRect, Filter(() => !Helper.IsUnitDummy(GetFilterUnit())));
        TriggerAddCondition(trigger, Condition(() =>
        {
            var u = GetTriggerUnit();
            foreach (var callback in _callbacks)
            {
                callback(u);
            }
            return false;
        }));
    }

    public void Register(Action<unit> callback)
    {
        if (_callbacks.IndexOf(callback) != -1)
        {
            return;
        }

        _callbacks.Add(callback);
    }
}