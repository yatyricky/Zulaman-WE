using StdLib;

public enum StatEventType
{
    None,
    MaxHp,
}

public enum StatId
{
    BaseHp,
    ExMaxHp,
}

public class StatConfigEntry
{
    public StatId ID;
    public string Name = "";
    public StatType Type;
    public string Description = "";
    public StatEventType EventType;
}

public class StatConfig
{
    public static List<StatConfigEntry> Data = new()
    {
        new StatConfigEntry{ID = StatId.BaseHp, Name = "basehp", Type = StatType.Int, Description = "basehp pts", EventType = StatEventType.MaxHp},
        new StatConfigEntry{ID = StatId.ExMaxHp, Name = "maxhp", Type = StatType.Int, Description = "ex max hp pts", EventType = StatEventType.MaxHp},
    };

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