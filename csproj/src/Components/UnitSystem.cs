using System;
using StdLib;

public class UnitSystem : Component
{
    private static bool _initialized;
    private readonly Dictionary<unit, GameObject> _units = [];

    public GameObject? GetUnit(unit? u)
    {
        if (u == null) return null;
        return _units.TryGetValue(u, out var obj) ? obj : null;
    }

    public List<GameObject> SnapshotUnits()
    {
        var result = new List<GameObject>();
        foreach (var (u, obj) in _units)
        {
            result.Add(obj);
        }
        return result;
    }

    public override void Awake()
    {
        if (_initialized) throw new InvalidOperationException("UnitSystem already initialized");
        _initialized = true;

        StatsComponent.EnsureGraphs();
        CreateUnitEvent.Instance.Register(d => OnUnitCreated(d.u));
        UnitRemovedEvent.Instance.Register(d => OnUnitRemoved(d.u));
        RegisterExistingUnits();
    }

    private void OnUnitCreated(unit u)
    {
        CreateUnitEntity(u, true);
    }

    private void OnUnitRemoved(unit u)
    {
        if (!_units.TryGetValue(u, out var obj)) return;
        _units.Remove(u);
        if (!obj.isDestroyQueued && !obj.isDestroyed)
        {
            obj.Destroy();
        }
    }

    private void CreateUnitEntity(unit u, bool reportMissing)
    {
        if (GetUnitTypeId(u) == 0) return;
        if (Helper.IsUnitDummy(u)) return;

        var reused = UnitRemovedEvent.Cancel(u);
        var old = GetUnit(u);
        if (old != null)
        {
            if (!reused)
            {
                throw new InvalidOperationException($"unit already has an entity: {Helper.GetUnitNameEx(u)} {I2S(GetUnitTypeId(u))}");
            }
            _units.Remove(u);
            old.Destroy();
        }

        if (UnitConfig.TryFindByUTID(GetUnitTypeId(u)) == null)
        {
            if (reportMissing)
            {
                ReportRegistrationError($"unit not configured: {Helper.GetUnitNameEx(u)} {I2S(GetUnitTypeId(u))}");
            }
            return;
        }

        var obj = new GameObject(Helper.GetUnitNameEx(u), Const.UnitsRoot);
        var entity = obj.AddComponent<UnitEntity>();
        entity.Bind(u);

        _units[u] = obj;

        obj.AddComponent<StatsComponent>();
        obj.AddComponent<BuffHolder>();
    }

    private void RegisterExistingUnits()
    {
        var group = CreateGroup();
        GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(() => true));
        var u = FirstOfGroup(group);
        while (u != null)
        {
            GroupRemoveUnit(group, u);
            if (GetUnit(u) == null)
            {
                CreateUnitEntity(u, false);
            }
            u = FirstOfGroup(group);
        }
        DestroyGroup(group);
    }

    private void ReportRegistrationError(string message)
    {
        Log.Info(Diagnostics.Fail(message));
        BJDebugMsg(message);
    }
}
