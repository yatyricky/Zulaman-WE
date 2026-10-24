using System;
using SFLib.Interop;
using StdLib;

public class StatsComponent : Component
{
    public unit owner = null!;
    private readonly Dictionary<StatId, StatValue> stats = [];

    // unit -> StatsComponent 反查,NewUnit 时登记
    public static readonly Dictionary<unit, StatsComponent> Components = new();

    public StatValue GetStat(StatId id)
    {
        return stats[id];
    }

    public bool HasStats()
    {
        return stats.Count > 0;
    }

    public override void Start()
    {
        foreach (var config in StatConfig.Data)
        {
            var val = new StatValue();
            switch (config.Type)
            {
                case StatType.Int:
                    val.intVal = 0;
                    break;
                case StatType.Float:
                    val.floatVal = 0f;
                    break;
                default:
                    throw new Exception($"Unhandled stat config {config.ID}");
            }
            stats[config.ID] = val;
        }

        var utid = GetUnitTypeId(owner);
        var unitConfig = UnitConfig.FindByUTID(utid);
        ModStats(unitConfig.BaseStats);
    }

    private static readonly List<int> PosLifeArr = [FourCC("AHP0"), FourCC("AHP1"), FourCC("AHP2"), FourCC("AHP3"), FourCC("AHP4"), FourCC("AHP5"), FourCC("AHP6"), FourCC("AHP7"), FourCC("AHP8"), FourCC("AHP9"), FourCC("AHP:"), FourCC("AHP;"), FourCC("AHP<"), FourCC("AHP="), FourCC("AHP>"), FourCC("AHP?"), FourCC("AHP@"), FourCC("AHPA"), FourCC("AHPB"), FourCC("AHPC"), FourCC("AHPD")];

    private static void UpdateStats(unit u, int amount, List<int> posArr, int negId)
    {
        var cap = (int)math.pow(2, posArr.Count);
        // validation
        if (amount < 0 && negId == 0)
        {
            amount = 0;
        }
        amount = Math.Clamp(amount, 0 - cap, cap - 1);

        if (amount == 0)
        {
            if (negId != 0 && GetUnitAbilityLevel(u, negId) > 0)
            {
                UnitRemoveAbility(u, negId);
            }
            foreach (var aid in posArr)
            {
                if (GetUnitAbilityLevel(u, aid) > 0)
                {
                    UnitRemoveAbility(u, aid);
                }
            }
        }
        else
        {
            if (amount < 0)
            {
                amount += cap;
                if (negId != 0 && GetUnitAbilityLevel(u, negId) == 0)
                {
                    UnitAddAbility(u, negId);
                    UnitMakeAbilityPermanent(u, true, negId);
                }
            }
            else
            {
                if (negId != 0 && GetUnitAbilityLevel(u, negId) > 0)
                {
                    UnitRemoveAbility(u, negId);
                }
            }
            var i = 0;
            while (amount > 0)
            {
                if (amount % 2 == 1)
                {
                    if (GetUnitAbilityLevel(u, posArr[i]) == 0)
                    {
                        UnitAddAbility(u, posArr[i]);
                        UnitMakeAbilityPermanent(u, true, posArr[i]);
                    }
                }
                else
                {
                    if (GetUnitAbilityLevel(u, posArr[i]) > 0)
                    {
                        UnitRemoveAbility(u, posArr[i]);
                    }
                }
                amount = (int)math.floor(amount / 2);
                i += 1;
            }
            while (i < posArr.Count)
            {
                if (GetUnitAbilityLevel(u, posArr[i]) > 0)
                {
                    UnitRemoveAbility(u, posArr[i]);
                }
                i += 1;
            }
        }
    }

    public static void UpdateMaxHp(StatsComponent comp)
    {
        UpdateStats(comp.owner, comp.stats[StatId.RMaxHp].intVal - 1, PosLifeArr, 0);
    }

    public static void NewUnit(CreateUnitEventData data)
    {
        var obj = new GameObject(Helper.GetUnitNameEx(data.u), Const.UnitsRoot);
        var comp = obj.AddComponent<StatsComponent>();
        comp.owner = data.u;
        Components[data.u] = comp;
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
        Components.Remove(data.u);
    }

    public static void Init()
    {
        CreateUnitEvent.Instance.Register(NewUnit);
        ConstructStatGraphs();
        UnitRemovedEvent.Instance.Register(OnUnitRemoved);
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
    };

    // 派生属性变更后立即写回 war3 层的同步器,在 ModStats 提交路径内按拓扑序调用
    private static readonly Dictionary<StatId, Action<StatsComponent>> statAppliers = new()
    {
        { StatId.RMaxHp, UpdateMaxHp },
    };

    private static StatValue CalcRMaxHp(StatsComponent comp)
    {
        var baseHp = comp.stats[StatId.BaseHp].intVal;
        var exMaxHp = comp.stats[StatId.ExMaxHp].intVal;
        var exPct = comp.stats[StatId.ExMapHpPct].floatVal;
        return new StatValue { intVal = MathRound((comp.strength * 10 + baseHp + exMaxHp) * (1f + exPct)) };
    }

    public int strength
    {
        get
        {
            return GetHeroStr(owner, true);
        }
    }
}
