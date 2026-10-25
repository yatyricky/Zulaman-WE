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
    MageDamageRes,
    AllDamageRes,

    Dodge,
    Parry,
    ParryPts,

    PhyxThorns,
    MageThorns,

    ExAp,
    PhyxCrit,
    PhyxCritDmg,
    PhyxHit,
    PhyxAmp,

    ExIas,
    ExCdr,

    ExSp,
    MageCrit,
    MageCritDmg,
    MagePierce,
    MageAmp,
    AllDmgAmp,
    HealAmp,
    AllAmp,
    HealTaken,
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

        new StatConfigEntry{ID= StatId.AllDamageRes, Type = StatType.Float, Description = "PhyxDamageRes"},

        new StatConfigEntry{ID = StatId.Strength, Type = StatType.Float, Description = "Strength"},
        new StatConfigEntry{ID = StatId.ExHRegen, Type = StatType.Float, Description = "ExHRegen"},
        new StatConfigEntry{ID = StatId.ExHRegenPct, Type = StatType.Float, Description = "ExHRegenPct"},
        new StatConfigEntry{ID = StatId.RHRegen, Type = StatType.Float, Description = "RHRegen"},
        new StatConfigEntry{ID = StatId.Intelligence, Type = StatType.Float, Description = "Intelligence"},
        new StatConfigEntry{ID = StatId.ExMRegen, Type = StatType.Float, Description = "ExMRegen"},
        new StatConfigEntry{ID = StatId.ExMRegenPct, Type = StatType.Float, Description = "ExMRegenPct"},
        new StatConfigEntry{ID = StatId.RMRegen, Type = StatType.Float, Description = "RMRegen"},

        new StatConfigEntry{ID = StatId.ExArmor, Type = StatType.Float, Description = "ExArmor"},
        new StatConfigEntry{ID = StatId.MageDamageRes, Type = StatType.Float, Description = "MageDamageRes"},

        new StatConfigEntry{ID = StatId.Dodge, Type = StatType.Float, Description = "Dodge"},
        new StatConfigEntry{ID = StatId.Parry, Type = StatType.Float, Description = "Parry"},
        new StatConfigEntry{ID = StatId.ParryPts, Type = StatType.Float, Description = "ParryPts"},

        new StatConfigEntry{ID = StatId.PhyxThorns, Type = StatType.Float, Description = "PhyxThorns"},
        new StatConfigEntry{ID = StatId.MageThorns, Type = StatType.Float, Description = "MageThorns"},

        new StatConfigEntry{ID = StatId.ExAp, Type = StatType.Float, Description = "ExAp"},
        new StatConfigEntry{ID = StatId.PhyxCrit, Type = StatType.Float, Description = "PhyxCrit"},
        new StatConfigEntry{ID = StatId.PhyxCritDmg, Type = StatType.Float, Description = "PhyxCritDmg"},
        new StatConfigEntry{ID = StatId.PhyxHit, Type = StatType.Float, Description = "PhyxHit"},
        new StatConfigEntry{ID = StatId.PhyxAmp, Type = StatType.Float, Description = "PhyxAmp"},

        new StatConfigEntry{ID = StatId.ExIas, Type = StatType.Float, Description = "ExIas"},
        new StatConfigEntry{ID = StatId.ExCdr, Type = StatType.Float, Description = "ExCdr"},

        new StatConfigEntry{ID = StatId.ExSp, Type = StatType.Float, Description = "ExSp"},
        new StatConfigEntry{ID = StatId.MageCrit, Type = StatType.Float, Description = "MageCrit"},
        new StatConfigEntry{ID = StatId.MageCritDmg, Type = StatType.Float, Description = "MageCritDmg"},
        new StatConfigEntry{ID = StatId.MagePierce, Type = StatType.Float, Description = "MagePierce"},
        new StatConfigEntry{ID = StatId.MageAmp, Type = StatType.Float, Description = "MageAmp"},
        new StatConfigEntry{ID = StatId.AllDmgAmp, Type = StatType.Float, Description = "AllDmgAmp"},
        new StatConfigEntry{ID = StatId.HealAmp, Type = StatType.Float, Description = "HealAmp"},
        new StatConfigEntry{ID = StatId.AllAmp, Type = StatType.Float, Description = "AllAmp"},
        new StatConfigEntry{ID = StatId.HealTaken, Type = StatType.Float, Description = "HealTaken"},
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