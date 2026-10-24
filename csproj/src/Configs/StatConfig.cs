using StdLib;

public enum StatId
{
    Strength,
    BaseHp,
    ExMaxHp,
    ExMapHpPct,
    RMaxHp,
    ExHRegen,
    ExHRegenPct,
    RHRegen,
    Intelligence,
    BaseMp,
    ExMaxMp,
    ExMapMpPct,
    RMaxMp,
    ExMRegen,
    ExMRegenPct,
    RMRegen,
    ExArmor,
    PhyxDamageRes,
    MageDamageRes,
    AllDamageRes,
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
        new StatConfigEntry{ID = StatId.RMaxHp, Type = StatType.Int, Description = "r max hp pts", Dependencies = [StatId.Strength, StatId.BaseHp, StatId.ExMaxHp, StatId.ExMapHpPct]},
        new StatConfigEntry{ID = StatId.BaseMp, Type = StatType.Int, Description = "basemp pts"},
        new StatConfigEntry{ID = StatId.ExMaxMp, Type = StatType.Int, Description = "ex max mp pts"},
        new StatConfigEntry{ID = StatId.ExMapMpPct, Type = StatType.Float, Description = "ex max mp %"},
        new StatConfigEntry{ID = StatId.RMaxMp, Type = StatType.Int, Description = "r max mp pts", Dependencies = [StatId.Intelligence, StatId.BaseMp, StatId.ExMaxMp, StatId.ExMapMpPct]},

        new StatConfigEntry{ID= StatId.PhyxDamageRes, Type = StatType.Float, Description = "PhyxDamageRes"},
        new StatConfigEntry{ID= StatId.AllDamageRes, Type = StatType.Float, Description = "PhyxDamageRes"},
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