using StdLib;

public enum StatId
{
    BaseHp,
    ExMaxHp,
    ExMapHpPct,
    RMaxHp,
}

public class StatConfigEntry
{
    public StatId ID;
    public StatType Type;
    public string Description = "";
    public List<StatId> Dependencies = [];
}

public class StatConfig
{
    public static List<StatConfigEntry> Data =
    [
        new StatConfigEntry{ID = StatId.BaseHp, Type = StatType.Int, Description = "basehp pts"},
        new StatConfigEntry{ID = StatId.ExMaxHp, Type = StatType.Int, Description = "ex max hp pts"},
        new StatConfigEntry{ID = StatId.ExMapHpPct, Type = StatType.Float, Description = "ex map hp %"},
        new StatConfigEntry{ID = StatId.RMaxHp, Type = StatType.Int, Description = "r max hp pts", Dependencies = [StatId.BaseHp, StatId.ExMaxHp, StatId.ExMapHpPct]},
    ];

    public static StatConfigEntry FindByID(StatId id)
    {
        foreach (var item in Data)
        {
            if (item.ID == id)
            {
                return item;
            }
        }
        throw new System.Exception("Not implemented");
    }
}