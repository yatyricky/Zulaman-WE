using System;
using StdLib;

public class StatsComponent : Component
{
    private unit? _owner;
    public unit owner => _owner ?? throw new InvalidOperationException("StatsComponent owner is not assigned");
    private readonly Dictionary<StatId, StatValue> stats = [];

    // unit -> StatsComponent 反查,NewUnit 时登记
    private static readonly Dictionary<unit, StatsComponent> Components = new();

    internal void Bind(unit u)
    {
        _owner = u;
    }

    public static bool TryFindComp(unit? u, out StatsComponent comp)
    {
        if (u != null && Components.TryGetValue(u, out var ret))
        {
            comp = ret;
            return true;
        }
        comp = null!;
        return false;
    }

    public static StatsComponent FindComp(unit u)
    {
        if (TryFindComp(u, out var ret))
        {
            return ret;
        }
        throw new Exception($"comp not found: {Helper.GetUnitNameEx(u)} {I2S(GetUnitTypeId(u))}");
    }

    public StatValue GetStat(StatId id)
    {
        return stats[id];
    }

    public bool HasStats()
    {
        return stats.Count > 0;
    }

    public static bool IsDerivedStat(StatId id)
    {
        return statCalculators.ContainsKey(id);
    }

    private bool _initialized;
    private bool _initializing;

    /// <summary>
    /// Initializes base stats immediately after the unit owner is assigned.
    /// BuffHolder registers during the same creation frame and needs HasStats()
    /// to be true before gameplay code can apply buffs to the new unit.
    /// </summary>
    public void EnsureInitialized()
    {
        if (_initialized) return;
        if (_initializing) throw new InvalidOperationException("reentrant StatsComponent initialization");

        _initializing = true;
        try
        {
            foreach (var config in StatConfig.Data)
            {
                stats[config.ID] = new StatValue(config.Type);
            }

            var utid = GetUnitTypeId(owner);
            var unitConfig = UnitConfig.FindByUTID(utid);
            ModStats(unitConfig.BaseStats);

            SetUnitState(owner, UNIT_STATE_MANA, GetStat(StatId.RMaxMp).intVal);
            _initialized = true;
        }
        finally
        {
            _initializing = false;
        }
    }

    public override void Start()
    {
        EnsureInitialized();
    }

    private static void SetAbility(unit u, int abilityId, bool enabled)
    {
        var level = GetUnitAbilityLevel(u, abilityId);
        if (enabled)
        {
            if (level == 0)
            {
                UnitAddAbility(u, abilityId);
                UnitMakeAbilityPermanent(u, true, abilityId);
            }
            return;
        }

        if (level > 0)
        {
            UnitRemoveAbility(u, abilityId);
        }
    }

    private static void UpdateStats(unit u, int amount, List<int> posArr, int negId)
    {
        var cap = 1 << posArr.Count;

        // validation
        if (amount < 0 && negId == 0)
        {
            amount = 0;
        }
        amount = Math.Clamp(amount, 0 - cap, cap - 1);

        var negative = amount < 0;
        if (negative)
        {
            amount += cap;
        }

        if (negId != 0)
        {
            SetAbility(u, negId, negative);
        }

        for (var i = 0; i < posArr.Count; i++)
        {
            SetAbility(u, posArr[i], (amount & (1 << i)) != 0);
        }
    }

    private static readonly List<int> PosLifeArr = [FourCC("AHP0"), FourCC("AHP1"), FourCC("AHP2"), FourCC("AHP3"), FourCC("AHP4"), FourCC("AHP5"), FourCC("AHP6"), FourCC("AHP7"), FourCC("AHP8"), FourCC("AHP9"), FourCC("AHP:"), FourCC("AHP;"), FourCC("AHP<"), FourCC("AHP="), FourCC("AHP>"), FourCC("AHP?"), FourCC("AHP@"), FourCC("AHPA"), FourCC("AHPB"), FourCC("AHPC"), FourCC("AHPD")];
    public static void UpdateMaxHp(StatsComponent comp)
    {
        UpdateStats(comp.owner, comp.stats[StatId.RMaxHp].intVal - 1, PosLifeArr, 0);
    }
    private static readonly List<int> PosManaArr = [FourCC("ALT0"), FourCC("ALT1"), FourCC("ALT2"), FourCC("ALT3"), FourCC("ALT4"), FourCC("ALT5"), FourCC("ALT6"), FourCC("ALT7"), FourCC("ALT8"), FourCC("ALT9"), FourCC("ALT:"), FourCC("ALT;"), FourCC("ALT<"), FourCC("ALT="), FourCC("ALT>"), FourCC("ALT?"), FourCC("ALT@")];
    public static void UpdateMaxMp(StatsComponent comp)
    {
        UpdateStats(comp.owner, comp.stats[StatId.RMaxMp].intVal, PosManaArr, 0);
    }

    private static void NewUnit(CreateUnitEventData data)
    {
        RegisterUnit(data.u);
    }

    private static void RegisterUnit(unit u, bool reportMissing = true)
    {
        if (GetUnitTypeId(u) == 0) return;
        if (Helper.IsUnitDummy(u)) return;

        var reused = UnitRemovedEvent.Cancel(u);
        if (Components.TryGetValue(u, out var oldComp))
        {
            if (reused)
            {
                Components.Remove(u);
                if (!oldComp.gameObject.isDestroyQueued && !oldComp.gameObject.isDestroyed)
                {
                    oldComp.gameObject.Destroy();
                }
            }
            else
            {
                throw new InvalidOperationException($"unit already registered: {Helper.GetUnitNameEx(u)} {I2S(GetUnitTypeId(u))}");
            }
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
        var comp = obj.AddComponent<StatsComponent>();
        comp.Bind(u);
        Components[u] = comp;

        try
        {
            comp.EnsureInitialized();
            obj.AddComponent<BuffHolder>();
        }
        catch
        {
            Components.Remove(u);
            if (!obj.isDestroyQueued)
            {
                obj.Destroy();
            }
            throw;
        }
    }

    private static void RegisterExistingUnits()
    {
        var group = CreateGroup();
        GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, Filter(() => true));
        while (true)
        {
            var u = FirstOfGroup(group);
            if (u == null) break;
            GroupRemoveUnit(group, u);
            if (Components.ContainsKey(u)) continue;
            RegisterUnit(u, false);
        }
        DestroyGroup(group);
    }

    private static void ReportRegistrationError(string message)
    {
        Log.Info(Diagnostics.Fail(message));
        BJDebugMsg(message);
    }

    private static readonly Dictionary<StatId, List<StatId>> statUseGraph = [];
    private static readonly List<StatId> statTopoOrder = [];

    private static void ConstructStatGraphs()
    {
        foreach (var config in StatConfig.Data)
        {
            foreach (var dep in config.Dependencies)
            {
                if (!statUseGraph.ContainsKey(dep))
                {
                    statUseGraph[dep] = [];
                }
                if (!statUseGraph[dep].Contains(config.ID))
                {
                    statUseGraph[dep].Add(config.ID);
                }
            }
        }

        BuildStatTopoOrder();
    }

    private static void BuildStatTopoOrder()
    {
        // 校验:配置 ID 不重复;声明依赖的必须有计算器
        var known = new List<StatId>();
        var indegree = new Dictionary<StatId, int>();
        foreach (var config in StatConfig.Data)
        {
            if (known.Contains(config.ID)) throw new Exception($"Duplicate stat config {config.ID}");
            known.Add(config.ID);
            if (statCalculators.ContainsKey(config.ID))
            {
                indegree[config.ID] = 0;
            }
            else if (config.Dependencies.Count > 0)
            {
                throw new Exception($"Stat {config.ID} declares dependencies but has no calculator");
            }
        }
        foreach (var (id, calc) in statCalculators)
        {
            if (!known.Contains(id)) throw new Exception($"Derived stat {id} has no StatConfig entry");
        }

        // 只对 派生->派生 的边计度,基础属性不参与排序
        foreach (var config in StatConfig.Data)
        {
            if (!statCalculators.ContainsKey(config.ID)) continue;
            foreach (var dep in config.Dependencies)
            {
                if (statCalculators.ContainsKey(dep))
                {
                    indegree[config.ID] = indegree[config.ID] + 1;
                }
            }
        }

        // Kahn:按 StatConfig.Data 顺序入队,保证输出确定性
        var ready = new List<StatId>();
        foreach (var config in StatConfig.Data)
        {
            if (indegree.TryGetValue(config.ID, out var d) && d == 0)
            {
                ready.Add(config.ID);
            }
        }
        for (var i = 0; i < ready.Count; i++)
        {
            var id = ready[i];
            statTopoOrder.Add(id);
            if (!statUseGraph.TryGetValue(id, out var dependents)) continue;
            foreach (var next in dependents)
            {
                indegree[next] = indegree[next] - 1;
                if (indegree[next] == 0)
                {
                    ready.Add(next);
                }
            }
        }

        // 有剩余即存在环
        if (statTopoOrder.Count != indegree.Count)
        {
            foreach (var config in StatConfig.Data)
            {
                if (indegree.ContainsKey(config.ID) && !statTopoOrder.Contains(config.ID))
                {
                    throw new Exception($"Stat dependency cycle involving {config.ID}");
                }
            }
        }
    }

    private static void OnUnitRemoved(UnitRemovedEventData data)
    {
        if (!Components.TryGetValue(data.u, out var comp)) return;
        Components.Remove(data.u);
        if (!comp.gameObject.isDestroyQueued && !comp.gameObject.isDestroyed)
        {
            comp.gameObject.Destroy();
        }
    }

    public static void Init()
    {
        CreateUnitEvent.Instance.Register(NewUnit);
        ConstructStatGraphs();
        UnitRemovedEvent.Instance.Register(OnUnitRemoved);
        RegisterExistingUnits();
    }

    public void ModStats(Dictionary<StatId, StatValue> values)
    {
        var changed = new List<StatId>();
        foreach (var (key, val) in values)
        {
            if (!stats.ContainsKey(key)) throw new Exception($"Unknown stat {key}");
            if (statCalculators.ContainsKey(key)) throw new Exception($"Derived stat {key} cannot be modified directly");
            var old = stats[key];
            var nv = old + val;
            stats[key] = nv;
            if (nv != old)
            {
                changed.Add(key);
                if (statAppliers.TryGetValue(key, out var apply)) apply(this);
            }
        }

        // 收集受影响的派生属性（BFS 传递闭包，List.Contains 去重）
        var affected = new List<StatId>();
        affected.AddRange(changed);
        for (var i = 0; i < affected.Count; i++)
        {
            if (statUseGraph.TryGetValue(affected[i], out var dependents))
            {
                foreach (var d in dependents)
                {
                    if (!affected.Contains(d))
                        affected.Add(d);
                }
            }
        }

        // 按拓扑序重算派生属性，值变化才计入 changed
        foreach (var id in statTopoOrder)
        {
            if (!affected.Contains(id)) continue;
            var old = stats[id];
            var nv = statCalculators[id](this);
            stats[id] = nv;
            if (nv != old)
            {
                changed.Add(id);
                if (statAppliers.TryGetValue(id, out var apply)) apply(this);
            }
        }

        // fire events
        foreach (var id in changed)
        {
            UnitStatEvent.Instance.ResponseCall(new UnitStatEventData { target = owner, statId = id, comp = this });
        }
    }

    private static readonly Dictionary<StatId, Func<StatsComponent, StatValue>> statCalculators = new()
    {
        { StatId.RMaxHp, CalcRMaxHp },
        { StatId.RMaxMp, CalcRMaxMp },
    };

    // 派生属性变更后立即写回 war3 层的同步器,在 ModStats 提交路径内按拓扑序调用
    private static readonly Dictionary<StatId, Action<StatsComponent>> statAppliers = new()
    {
        { StatId.RMaxHp, UpdateMaxHp },
        { StatId.RMaxMp, UpdateMaxMp },
    };

    private static StatValue CalcRMaxHp(StatsComponent comp)
    {
        var baseHp = comp.stats[StatId.BaseHp].intVal;
        var exMaxHp = comp.stats[StatId.ExMaxHp].intVal;
        var exPct = comp.stats[StatId.ExMapHpPct].floatVal;
        return Math.RoundToInt((comp.strength * 10 + baseHp + exMaxHp) * (1f + exPct));
    }

    private static StatValue CalcRMaxMp(StatsComponent comp)
    {
        var baseV = comp.stats[StatId.BaseMp].intVal;
        var exV = comp.stats[StatId.ExMaxMp].intVal;
        var pctV = comp.stats[StatId.ExMapMpPct].floatVal;
        return Math.RoundToInt((comp.intelligence * 10 + baseV + exV) * (1f + pctV));
    }

    public int strength => GetHeroStr(owner, true);
    public int agility => GetHeroAgi(owner, true);
    public int intelligence => GetHeroInt(owner, true);

    public int primaryAttr
    {
        get
        {
            var uc = UnitConfig.FindByUTID(GetUnitTypeId(owner));
            switch (uc.PrimaryAttr)
            {
                case UnitAttrType.Strength:
                    return strength;
                case UnitAttrType.Agility:
                    return agility;
                case UnitAttrType.Intelligence:
                    return intelligence;
            }
            return 0;
        }
    }

    public int meleeLow
    {
        get
        {
            return BlzGetUnitBaseDamage(owner, 0) + BlzGetUnitDiceNumber(owner, 0);
        }
    }

    public int meleeHigh
    {
        get
        {
            return BlzGetUnitBaseDamage(owner, 0) + BlzGetUnitDiceNumber(owner, 0) * BlzGetUnitDiceSides(owner, 0);
        }
    }

    public float armor
    {
        get
        {
            return BlzGetUnitArmor(owner);
        }
    }

    public float phyxDamageTakenPct
    {
        get
        {
            // armor
            var amr = armor;
            var v = 0f;
            if (armor > 0)
            {
                var t = amr * 0.02f;
                v = 1 - t / (1 + t);
            }
            else
            {
                v = 1 - Math.Pow(amr, 0.98f);
            }
            // res
            v *= 1 - GetStat(StatId.AllDamageRes).floatVal;
            return v;
        }
    }

    public float mageDamageTakenPct => 1 - GetStat(StatId.MageDamageRes).floatVal - GetStat(StatId.AllDamageRes).floatVal;

    public float phyxDamageDealt => GetStat(StatId.PhyxAmp).floatVal + GetStat(StatId.AllAmp).floatVal;
    public float mageDamageDealt => GetStat(StatId.MageAmp).floatVal + GetStat(StatId.AllAmp).floatVal;
    public float sp => intelligence + GetStat(StatId.ExSp).floatVal;
}
