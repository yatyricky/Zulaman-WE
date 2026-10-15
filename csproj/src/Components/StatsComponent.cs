using System;
using SFLib.Interop;
using StdLib;

public class StatsComponent : Component
{

    public unit owner = null!;
    private Dictionary<StatId, StatValue> stats = new();

    public override void Start()
    {
        foreach (var config in StatConfig.Data)
        {
            var val = new StatValue();
            switch (config.Type)
            {
                case StatType.INT:
                    val.intVal = 0;
                    break;
                case StatType.FLOAT:
                    val.floatVal = 0f;
                    break;
                default:
                    throw new Exception($"Unhandled stat config {config.ID}");
            }
            stats[config.ID] = val;
        }

        var utid = GetUnitTypeId(owner);
        var unitConfig = UnitConfig.FindByUTID(utid);
        var events = new Dictionary<StatEventType, int>();
        foreach (var (key, value) in unitConfig.BaseStats)
        {
            AddValueInPlace(stats[key], value);
            var modStat = StatConfig.FindByID(key);
            events[modStat.EventType] = 1;
        }

        foreach (var (et, _) in events)
        {
            statEventCalls[et](this);
        }
    }

    private static Dictionary<StatEventType, Action<StatsComponent>> statEventCalls = new()
    {
        {StatEventType.NONE, (u) => {}},
        {StatEventType.MAX_HP, UpdateMaxHp},
    };

    private static readonly List<int> PosLifeArr = [FourCC("AHP0"), FourCC("AHP1"), FourCC("AHP2"), FourCC("AHP3"), FourCC("AHP4"), FourCC("AHP5"), FourCC("AHP6"), FourCC("AHP7"), FourCC("AHP8"), FourCC("AHP9"), FourCC("AHP:"), FourCC("AHP;"), FourCC("AHP<"), FourCC("AHP="), FourCC("AHP>"), FourCC("AHP?"), FourCC("AHP@"), FourCC("AHPA"), FourCC("AHPB"), FourCC("AHPC"), FourCC("AHPD")];

    private static void UpdateStats(unit u, int amount, List<int> posArr, int negId)
    {
        var cap = 2 ^ posArr.Count;
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
        var amount = comp.stats[StatId.BASE_HP].intVal + comp.stats[StatId.EX_MAX_HP].intVal;
        UpdateStats(comp.owner, amount, PosLifeArr, 0);
    }

    public static void AddValueInPlace(StatValue left, StatValue right)
    {
        left.intVal += right.intVal;
        left.floatVal += right.floatVal;
    }

    public static void NewUnit(CreateUnitEventData data)
    {
        var obj = new GameObject(Helper.GetUnitNameEx(data.u), Const.UnitsRoot);
        var comp = obj.AddComponent<StatsComponent>();
        comp.owner = data.u;
    }

    public static void Init()
    {
        CreateUnitEvent.Instance.Register(NewUnit);
    }
}
